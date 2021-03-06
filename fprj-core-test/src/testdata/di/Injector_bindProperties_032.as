package testdata.di
{
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.SkinnableContainer;
	
	import testdata.TestUser;
	import testdata.TestUserProfile;

	public class Injector_bindProperties_032 extends SkinnableContainer
	{
		[Bindable]
		public var model:Injector_bindProperties_032_Model;
		
		[SkinPart(required="true")]
		[PropertyBinding(user="model.user@", userProfile="model.user.profile@")]
		public var thePart:Injector_bindProperties_032_SkinPart;
		
		public function Injector_bindProperties_032()
		{
			model = new Injector_bindProperties_032_Model;
			model.user = new TestUser();
			model.user.profile = new TestUserProfile;
			model.user.profile.email = "def@xyz.com"
			this.setStyle("skinClass", Injector_bindProperties_032Skin);
		}
		
		public function show():void
		{
			PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject);
		}
		
		public function hide():void
		{
			PopUpManager.removePopUp(this);
		}
	}
}