package testdata
{
	import flash.display.DisplayObject;
	
	import mx.controls.AdvancedDataGrid;
	import mx.core.FlexGlobals;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.SkinnableContainer;

	[EventHandling(dispatcher="dataGrid",event="mx.events.ListEvent.ITEM_DOUBLE_CLICK",handler="dataGrid_itemDoubleClick")]
	public class Injector_attachEventListeners_015 extends SkinnableContainer
	{
		public function Injector_attachEventListeners_015()
		{
			this.setStyle("skinClass", Injector_attachEventListeners_015Skin);
		}
		
		public function show():void
		{
			PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject);
		}
		
		[SkinPart(required="true")]
		[EventHandling(event="mx.events.ListEvent.CHANGE",handler="dataGrid_change")]
		public var dataGrid:AdvancedDataGrid;
		
		public function dataGrid_itemDoubleClick(event:ListEvent):void
		{
		}
		public function dataGrid_change(event:ListEvent):void
		{
		}
	}
}