package net.fproject.calendar
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.fproject.fproject_internal;
	import net.fproject.utils.DateTimeUtil;
	import net.fproject.utils.GregorianCalendar;
	import net.fproject.utils.LoggingUtil;
	import net.fproject.utils.LruCache;
	import net.fproject.utils.MessageUtil;
	import net.fproject.utils.ResourceUtil;
	import net.fproject.core.Time;
	import net.fproject.core.TimeRange;
	import net.fproject.core.TimeUnit;

	/**
	 * FlexUnit test case class for method<br/>
	 * <code>public function setPeriodToNonWorking(fromDate:Date, toDate:Date):void</code><br/>
	 * of class<br/>
	 * net.fproject.calendar.WorkCalendar
	 */
	public class WorkCalendar_setPeriodToNonWorking
	{
		private var workcalendar:WorkCalendar;

		[Before]
		public function runBeforeEveryTest():void
		{
			workcalendar = new WorkCalendar();
			//Your test data initialization
		}

		[After]
		public function runAfterEveryTest():void
		{
			workcalendar = null;
			//Your test data cleaning
		}

		[Test (description="Normal case: [fromDate = new Date(), toDate = new Date()]")]
		/**
		 * Test Case Type: Normal<br/>
		 * <br/>
		 * INPUT VALUES:<br/>
		 * <code>fromDate = new Date()</code><br/>
		 * <code>toDate = new Date()</code><br/>
		 * <br/>
		 * OUTPUT EXPECTED:<br/>
		 * ---- expectations ----
		 *
		 */
		public function testCase001():void
		{
			var fromDate:Date = new Date();
			var toDate:Date = new Date();
			workcalendar.setPeriodToNonWorking(fromDate, toDate);
			//---- Place result assertion here ----
			// You must replace this code by function specifications or 
			// the test always returns false!
			assertFalse(true);
			//-------------------------------------
		}

		[Test (description="Boundary case: [fromDate = null, toDate = new Date()]")]
		/**
		 * Test Case Type: Boundary<br/>
		 * <br/>
		 * INPUT VALUES:<br/>
		 * <code>fromDate = null</code><br/>
		 * <code>toDate = new Date()</code><br/>
		 * <br/>
		 * OUTPUT EXPECTED:<br/>
		 * ---- expectations ----
		 *
		 */
		public function testCase002():void
		{
			var fromDate:Date = null;
			var toDate:Date = new Date();
			workcalendar.setPeriodToNonWorking(fromDate, toDate);
			//---- Place result assertion here ----
			// You must replace this code by function specifications or 
			// the test always returns false!
			assertFalse(true);
			//-------------------------------------
		}

		[Test (description="Boundary case: [fromDate = new Date(), toDate = null]")]
		/**
		 * Test Case Type: Boundary<br/>
		 * <br/>
		 * INPUT VALUES:<br/>
		 * <code>fromDate = new Date()</code><br/>
		 * <code>toDate = null</code><br/>
		 * <br/>
		 * OUTPUT EXPECTED:<br/>
		 * ---- expectations ----
		 *
		 */
		public function testCase003():void
		{
			var fromDate:Date = new Date();
			var toDate:Date = null;
			workcalendar.setPeriodToNonWorking(fromDate, toDate);
			//---- Place result assertion here ----
			// You must replace this code by function specifications or 
			// the test always returns false!
			assertFalse(true);
			//-------------------------------------
		}

		[Test (description="Boundary case: [fromDate = null, toDate = null]")]
		/**
		 * Test Case Type: Boundary<br/>
		 * <br/>
		 * INPUT VALUES:<br/>
		 * <code>fromDate = null</code><br/>
		 * <code>toDate = null</code><br/>
		 * <br/>
		 * OUTPUT EXPECTED:<br/>
		 * ---- expectations ----
		 *
		 */
		public function testCase004():void
		{
			var fromDate:Date = null;
			var toDate:Date = null;
			workcalendar.setPeriodToNonWorking(fromDate, toDate);
			//---- Place result assertion here ----
			// You must replace this code by function specifications or 
			// the test always returns false!
			assertFalse(true);
			//-------------------------------------
		}

	}
}