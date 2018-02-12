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
	public class CalendarPreferences : DockItemPreferences
	{
		[Description(nick = "icon style", blurb = "switch the icon between elementary style or gnome style.")]
		public bool Elementary { get; set; }

		public CalendarPreferences.with_file (GLib.File file)
		{
			base.with_file (file);
		}

		protected override void reset_properties ()
		{
			Elementary = true;
		}
	}
}
