//
//  Copyright (C) 2011 Robert Dyer
//
//  This file is part of Plank.
//
//  Plank is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Plank is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky
{
	public class CalendarDockItem : DockletItem
	{
		const string THEME_BASE_URI = "resource://" + Docky.G_RESOURCE_PATH + "/themes/";

		Pango.Layout layout;
		uint timer_id = 0U;
		int minute;
		string current_theme;

		/**
		 * {@inheritDoc}
		 */
		public CalendarDockItem.with_dockitem_file (GLib.File file)
		{
			GLib.Object (Prefs: new CalendarPreferences.with_file (file));
		}

		construct
		{
			// shared by all text
			layout = new Pango.Layout (Gdk.pango_context_get ());
			var font_description = new Gtk.Style ().font_desc;
			font_description.set_weight (Pango.Weight.NORMAL);
			layout.set_font_description (font_description);
			layout.set_ellipsize (Pango.EllipsizeMode.NONE);

			Icon = "office-calendar";
			Text = "date";

			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;
			prefs.notify["Elementary"].connect (handle_prefs_changed);

			timer_id = Gdk.threads_add_timeout (1000, (SourceFunc) update_timer);
			current_theme = (prefs.Elementary ? THEME_BASE_URI + "elementary" : THEME_BASE_URI + "gnome");
		}

		~CalendarDockItem ()
		{
			if (timer_id > 0U)
				GLib.Source.remove (timer_id);

			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;
			prefs.notify["Elementary"].disconnect (handle_prefs_changed);
		}

		bool update_timer ()
		{
			var now = new DateTime.now_local ();
			if (minute != now.get_minute ()) {
				reset_icon_buffer ();
				minute = now.get_minute ();
			}

			return true;
		}

		void handle_prefs_changed ()
		{
			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;
			current_theme = (prefs.Elementary ? THEME_BASE_URI + "elementary" : THEME_BASE_URI + "gnome");

			reset_icon_buffer ();
		}

		protected override void draw_icon (Surface surface)
		{
			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;

			var now = new DateTime.now_local ();
			Text = now.format ("%A, %d %B %Y");

			var size = int.max (surface.Width, surface.Height);
			render_calendar (surface, now, size);
		}

		void render_file_onto_context (Cairo.Context cr, string uri, int size)
		{
			var pbuf = DrawingService.load_icon (uri, size, size);
			Gdk.cairo_set_source_pixbuf (cr, pbuf, 0, 0);
			cr.paint ();
		}

		void render_calendar (Surface surface, DateTime now, int size)
		{
			int center = size / 2;
			var radius = center;

			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;
			unowned Cairo.Context cr = surface.Context;

			// useful sizes
			int daySize = (surface.Height * 2) / 11;
			int dateSize = (surface.Height * 3) / 6 ;
			int ampmSize = daySize / 2;
			int spacing = surface.Height / 13;

			render_file_onto_context (cr, current_theme + "/calendar-drop-shadow.svg", radius * 2);
			render_file_onto_context (cr, current_theme + "/calendar-face-shadow.svg", radius * 2);
			render_file_onto_context (cr, current_theme + "/calendar-face.svg", radius * 2);
			render_file_onto_context (cr, current_theme + "/calendar-marks.svg", radius * 2);

			render_file_onto_context (cr, current_theme + "/calendar-glass.svg", radius * 2);
			render_file_onto_context (cr, current_theme + "/calendar-frame.svg", radius * 2);
			layout.set_width ((int) (surface.Width * Pango.SCALE));

			int timeYOffset = daySize - spacing;
			int timeXOffset = 0;

			//day and Color
			var dayName = now.format ("%u");
			var rdayColor = ((dayName == "7") ? 0.5 : 0);
			var bdayColor = ((dayName == "6") ? 0.5 : 0);

			if (prefs.Elementary) {
				// draw the day, outlined
				layout.get_font_description ().set_absolute_size ((int) (daySize * Pango.SCALE));
				layout.set_text (now.format ("%a"), -1);
				Pango.Rectangle ink_rect, logical_rect;
				layout.get_pixel_extents (out ink_rect, out logical_rect);

				timeYOffset = surface.Height / 13;
				timeXOffset = (surface.Width - ink_rect.width) / 2;
				cr.move_to (timeXOffset, timeYOffset);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0.1);
				cr.set_source_rgba (0.2, 0.2, 1, 0);
				cr.stroke_preserve ();
				cr.set_source_rgba (rdayColor, 0, bdayColor, 0.7);
				cr.fill ();

				// draw the date, outlined
				layout.get_font_description ().set_absolute_size ((int) (dateSize * Pango.SCALE));
				layout.set_text (now.format ("%d"), -1);
				layout.get_pixel_extents (out ink_rect, out logical_rect);
				cr.move_to ((surface.Width - ink_rect.width) * 5 / 12, timeYOffset + spacing * 2);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0);
				cr.set_source_rgba (1, 1, 1, 1);
				cr.stroke_preserve ();
				cr.set_source_rgba (rdayColor, 0, bdayColor, 0.6);
				cr.fill ();

				// draw the month and year, outlined
				layout.get_font_description ().set_absolute_size ((int) (ampmSize * Pango.SCALE));
				layout.set_text (now.format ("%m / %y"), -1);
				layout.get_pixel_extents (out ink_rect, out logical_rect);
				cr.move_to ((surface.Width - ink_rect.width) / 2, surface.Height - ampmSize * 3 + spacing / 2);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0.8);
				cr.set_source_rgba (0, 0, 0, 0.1);
				cr.stroke_preserve ();
				cr.set_source_rgba (0, 0, 0, 0.8);
				cr.fill ();
			} else {
				// useful sizes
				daySize = surface.Height / 10;
				dateSize = (daySize * 4) / 1  ;
				ampmSize = (daySize * 5) / 6;
				spacing = (daySize * 3) / 4;
				// draw the day, outlined
				layout.get_font_description ().set_absolute_size ((int) (daySize * Pango.SCALE));
				layout.set_text (now.format ("%a"), -1);
				Pango.Rectangle ink_rect, logical_rect;
				layout.get_pixel_extents (out ink_rect, out logical_rect);

				timeYOffset = spacing * 2 + daySize;
				timeXOffset = surface.Width / 4;
				cr.move_to (timeXOffset, timeYOffset);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0);
				cr.set_source_rgba (0.2, 0.2, 0.2, 1);
				cr.stroke_preserve ();
				cr.set_source_rgba (rdayColor, 0, bdayColor, 0.8);
				cr.fill ();

				// draw the date, outlined
				timeYOffset = timeYOffset + spacing / 3;
				layout.get_font_description ().set_absolute_size ((int) (dateSize * Pango.SCALE));
				layout.set_text (now.format ("%d"), -1);
				layout.get_pixel_extents (out ink_rect, out logical_rect);
				cr.move_to ((surface.Width - ink_rect.width) * 5 / 11, timeYOffset);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0.3);
				cr.set_source_rgba (0, 0, 0, 0.1);
				cr.stroke_preserve ();
				cr.set_source_rgba (rdayColor, 0, bdayColor, 0.7);
				cr.fill ();

				// draw the month and or year, outlined
				timeYOffset = timeYOffset + dateSize + spacing;
				layout.get_font_description ().set_absolute_size ((int) (ampmSize * Pango.SCALE));
				layout.set_text (now.format ("%b"), -1);
				layout.get_pixel_extents (out ink_rect, out logical_rect);
				cr.move_to (surface.Width / 2 + ink_rect.width, timeYOffset);

				Pango.cairo_layout_path (cr, layout);
				cr.set_line_width (0.8);
				cr.set_source_rgba (0, 0, 0, 0.1);
				cr.stroke_preserve ();
				cr.set_source_rgba (0, 0, 0, 0.8);
				cr.fill ();
			}
		}

		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items ()
		{
			unowned CalendarPreferences prefs = (CalendarPreferences) Prefs;
			var items = new Gee.ArrayList<Gtk.MenuItem> ();

			var checked_item = new Gtk.CheckMenuItem.with_mnemonic (_("_Calendar"));

			checked_item = new Gtk.CheckMenuItem.with_mnemonic (_("style: elementary / gnome"));
			checked_item.active = prefs.Elementary;
			checked_item.activate.connect (() => {
				prefs.Elementary = !prefs.Elementary;
			});
			items.add (checked_item);

			return items;
		}
	}
}
