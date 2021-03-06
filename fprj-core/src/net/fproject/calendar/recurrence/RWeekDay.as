﻿///////////////////////////////////////////////////////////////////////////////
//
// © Copyright f-project.net 2010-present.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////
package net.fproject.calendar.recurrence
{
    import mx.resources.ResourceManager;
    import mx.utils.StringUtil;
    
    import net.fproject.utils.LoggingUtil;
    import net.fproject.utils.ResourceUtil;

	/**
	 * The RWeekDay class represents a recurrence week day.
	 * <p>
	 * The <code>modifier</code> is used to specify the nth week day in the month, starting
	 * from the beginning of the month if the modifier is positive or the end of
	 * the month if the modifier is negative.
	 * </p>
	 */
    public class RWeekDay
    {
        private var _day:int = -1;
		
		/**
		 * <p>
		 * The modifier of this week day.
		 * </p>
		 * <ul>
		 * <li>0 means every specified week day of the month (for example, "MO" means
		 * every Monday).</li>
		 * <li>A positive number means the nth specified week day in the month (for
		 * example, "2MO" means the second Monday of the month).</li>
		 * <li>A negative number means the nth specified week day in the month
		 * starting from the end of the month (for example, "-1MO" means the last
		 * Monday of the month).</li>
		 * </ul>
		 */
        public var modifier:int;
		
        private var _weekDay:String;
        public static const SU:String = "SU";
        public static const MO:String = "MO";
        public static const TU:String = "TU";
        public static const WE:String = "WE";
        public static const TH:String = "TH";
        public static const FR:String = "FR";
        public static const SA:String = "SA";
        public static const WEEK_DAYS:Array = [SU, MO, TU, WE, TH, FR, SA];

        public function RWeekDay(modifier:int = 0, day:int = 0)
        {
            this.day = day;
            this.modifier = modifier;
        }

        public function set weekDay(value:String) : void
        {
            this._weekDay = value;
            this._day = WEEK_DAYS.indexOf(this._weekDay);
        }

		/**
		 * <p>
		 * The week day.
		 * </p>
		 * <p>
		 * One of "SU", "MO", "TU", "WE", "TH", "FR", "SA".
		 * </p>
		 */
        public function get weekDay() : String
        {
            return this._weekDay;
        }

        public function set day(value:int) : void
        {
            if (value < 0 || value >= 7)
            {
                value = 0;
            }
            this._day = value;
            this._weekDay = WEEK_DAYS[this.day];
        }

		/**
		 * <p>
		 * Day number according to the definition of <code>Date.day</code>.
		 * The value must be in range from 0 (SU) to 6 (SA)
		 * </p>
		 */
        public function get day() : int
        {
            return this._day;
        }

        public function toString() : String
        {
            return (this.modifier == 0 ? ("") : (this.modifier)) + this.weekDay;
        }

		/**
		 * <p>
		 * Parses the string and returns a <code>WeekDay</code> instance.
		 * </p>
		 * <p>
		 * An error is thrown if the string is not parsed successfully.
		 * </p>
		 * @param value The string to parse.
		 * @return A <code>WeekDay</code> instance.
		 */
        public static function parse(value:String) : RWeekDay
        {
            var wd:RWeekDay = new RWeekDay;
            var count:int = 0;
            value = StringUtil.trim(value);
            var s:String = value.charAt(count);
            var sign:int = 1;
            var b:Boolean = false;
            if (s == "+")
            {
                sign = 1;
                b = true;
                count++;
            }
            else if (s == "-")
            {
                sign = -1;
                b = true;
                count++;
            }
            s = value.charAt(count);
            var sNum:String = "";
            while (isDigit(s))
            {                
                b = true;
                sNum = sNum + s;
                count++;
                s = value.charAt(count);
            }
            if (b)
            {
                if (sNum == "")
                {
                    sNum = "1";
                }
                wd.modifier = sign * int(sNum);
            }
            else
            {
                wd.modifier = 0;
            }
            if (!isLetter(s))
            {
				LoggingUtil.logAndThrowError(
					RWeekDay, ResourceUtil.FPRJ_CALENDAR, 14, null, ResourceUtil.FPRJ_CALENDAR_BUNDLE, 
					"parse.error", [value]);
            }
            var sWd:String = s;
            count++;
            s = value.charAt(count);
            sWd = sWd + s;
            sWd = sWd.toUpperCase();
            if (count != (value.length - 1) || WEEK_DAYS.indexOf(sWd) == -1)
            {
				LoggingUtil.logAndThrowError(
					RWeekDay, ResourceUtil.FPRJ_CALENDAR, 14, null, ResourceUtil.FPRJ_CALENDAR_BUNDLE, 
					"parse.error", [value]);
            }
            wd.weekDay = sWd;
            return wd;
        }

        private static function isLetter(s:String) : Boolean
        {
            s = s.toUpperCase();
            return s >= "A" && s <= "Z";
        }

        private static function isDigit(s:String) : Boolean
        {
            return s >= "0" && s <= "9";
        }

    }
}
