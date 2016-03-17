///////////////////////////////////////////////////////////////////////////////
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
package net.fproject.collection
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ICollectionView;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.rpc.CallResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import net.fproject.active.ActiveService;
	
	/**
	 * 
	 * The <code>CollectionChangeManager</code> class manages the set of editing items on a 
	 * <code>ICollectionView</code> so that these sets can be retrieved after a period of time 
	 * inwhich user has made several interactions to the <code>ICollectionView</code>.
	 * 
	 * @see #getSaveItems()
	 * @see #getDeleteItems()
	 * 
	 * @author Bui Sy Nguyen
	 * 
	 */
	public class CollectionChangeManager
	{
		private static var _instance:CollectionChangeManager;
		
		/**
		 * Singleton of collection change manager.<br/>
		 * At a time, there is only one instance of <code>CollectionChangeManager</code> to be used.
		 * @return An unique instance of <code>CollectionChangeManager</code>
		 * 
		 */		
		public static function getInstance():CollectionChangeManager
		{
			if(_instance == null)
				_instance = new CollectionChangeManager();
			return _instance;
		}
		
		private static var _collectionToChangeItems:Dictionary = new Dictionary(true);
		private static var _services:Dictionary = new Dictionary(true);
		private static var _attributes:Dictionary = new Dictionary(true);
		private static var _unregisterPending:Dictionary = new Dictionary(true);
		
		/**
		 * Get all saved (inserted or updated) items
		 * @param collection the collection to check.
		 * @return an array of saved items. <code>null</code> if nothing found.
		 * 
		 */
		public function getSaveItems(collection:ICollectionView):Array
		{
			if(_collectionToChangeItems[collection] !== undefined)
			{
				var items:Array = _collectionToChangeItems[collection].insertItems;
				for each (var o:Object in _collectionToChangeItems[collection].updateItems)
				{
					if(items.indexOf(o) == -1)
						items.push(o);
				}
				return items;
			}
			else
				return null;
		}
		
		/**
		 * Get all inserted items
		 * @param collection the collection to check.
		 * @return an array of inserted items. <code>null</code> if nothing found.
		 * 
		 */
		public function getInsertItems(collection:ICollectionView):Array
		{
			if(_collectionToChangeItems[collection] !== undefined)
				return _collectionToChangeItems[collection].insertItems;
			else
				return null;
		}
		
		/**
		 * Get all updated items
		 * @param collection the collection to check.
		 * @return an array of updated items. <code>null</code> if nothing found.
		 * 
		 */
		public function getUpdateItems(collection:ICollectionView):Array
		{
			if(_collectionToChangeItems[collection] !== undefined)
				return _collectionToChangeItems[collection].updateItems;
			else
				return null;
		}
		
		/**
		 * Get all deleted items
		 * @param collection the collection to check.
		 * @return an array of deleted items. <code>null</code> if nothing found.
		 * 
		 */
		public function getDeleteItems(collection:ICollectionView):Array
		{
			if(_collectionToChangeItems[collection] !== undefined)
				return _collectionToChangeItems[collection].deleteItems;
			else
				return null;
		}
		
		/**
		 * Check if have the data change on an collection
		 * @param collection the collection to check.
		 * @return true if have data change, false in otherwise
		 * 
		 */
		public function haveChanges(collection:ICollectionView):Boolean
		{
			if(_collectionToChangeItems[collection] === undefined)
				return false;
			return (getInsertItems(collection).length > 0 || getUpdateItems(collection).length > 0 || getDeleteItems(collection).length > 0);
		}
		
		/**
		 * Reset changes history of a collection to the initial value
		 * @param collection the collection want to reset
		 * 
		 */
		public function resetCollectionChange(collection:Object):void
		{
			_collectionToChangeItems[collection] = {deleteItems:[], insertItems:[], updateItems:[], paused: false};
		}
		
		/**
		 * Register a collection to change manager. After this, all change events of
		 * collection will be recorded. 
		 * @param collection the collection to start listening.
		 * 
		 */
		public function registerCollection(collection:ICollectionView):void
		{
			if(collection)
			{
				unregisterCollection(collection);
				resetCollectionChange(collection);
				collection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
					collection_collectionChangeHandler, false, 0, true);
				delete _unregisterPending[collection];
			}
		}
		
		/**
		 * Unregister a collection from this change manager. 
		 * @param collection the collection to be removed.
		 * 
		 */
		public function unregisterCollection(collection:ICollectionView):void
		{
			if(collection && _collectionToChangeItems[collection] !== undefined)
			{
				if (isSaveAutomationOn(collection))
				{
					if (haveChanges(collection))
					{
						_unregisterPending[collection] = true;
						return;
					}
					disableSaveAutomation(collection);
				}
				
				collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, 
					collection_collectionChangeHandler);
				delete _collectionToChangeItems[collection];
			}
		}	
		
		/**
		 * Check if the collection has been enable the save automation features
		 * @param collection the collection to check.
		 * @return true the features has enable, false in otherwise
		 * 
		 */
		public function isSaveAutomationOn(collection:ICollectionView):Boolean
		{
			return 	_services[collection] !== undefined;
		}
		
		/**
		 * Enable the save automation features
		 * @param collection the collection to enable save automation features
		 * @param service the service use to save data
		 * @param attributes the array attributes of data will be save.
		 * attributes = null to save all attributes
		 * 
		 */
		public function enableSaveAutomation(collection:ICollectionView, service:ActiveService, attributes:Array=null):void
		{
			if (!isRegistered(collection))
				registerCollection(collection);
			_services[collection] = service;
			_attributes[collection] = attributes;
		}
		
		/**
		 * Disable save automation features'
		 * @param collection the collection to Disable save automation features
		 * 
		 */
		public function disableSaveAutomation(collection:ICollectionView):void
		{
			delete _services[collection];
			delete _attributes[collection];
		}
		
		/**
		 * Check for register a collection from this change manager. 
		 * @param collection the collection want to check.
		 * return true if the collection had registed
		 * return false if the collection hadn't registed
		 * 
		 */
		public function isRegistered(collection:ICollectionView):Boolean
		{
			return collection != null && _collectionToChangeItems[collection] !== undefined;
		}
		
		/**
		 * Temporarily stop listening to COLLECTION_CHANGE event
		 * 
		 * @see #resume()
		 * 
		 */
		public function pause(collection:ICollectionView):void
		{
			if (_collectionToChangeItems[collection]!== undefined)
				_collectionToChangeItems[collection].paused = true;
		}
		
		/**
		 * Resume listening to COLLECTION_CHANGE event
		 * 
		 * @see #pause()
		 */
		public function resume(collection:ICollectionView):void
		{
			if (_collectionToChangeItems[collection] !== undefined)
				_collectionToChangeItems[collection].paused = false;
		}
		
		/**
		 * Insert new values to insertItems array
		 * @param items the list item want to add to insertItems array.
		 * @param collection the collection have data inserrt. 
		 * Use as the key on Dictionary to find insertItems array
		 * 
		 */
		private function insertItems(items:Array, collection:Object):void
		{
			var deletedItems:Array = _collectionToChangeItems[collection].deleteItems;
			var insertedItems:Array = _collectionToChangeItems[collection].insertItems;
			var deletedItemCollection:AdvancedArrayCollection = new AdvancedArrayCollection;
			deletedItemCollection.source = deletedItems;
			
			for each (var item:Object in items)
			{
				if(item is PropertyChangeEvent)
					item = item.source;
				
				var index:int = deletedItemCollection.getItemIndex(item);
				if (index != -1)
					deletedItemCollection.removeItemAt(index);
				else if (insertedItems.indexOf(item) == -1)
					insertedItems.push(item);
			}
		}
		
		/**
		 * Insert new values to updateItems array
		 * @param items the list item want to add to updateItems array.
		 * @param collection the collection have data update. 
		 * Use as the key on Dictionary to find updateItems array
		 * 
		 */
		private function updateItems(items:Array, collection:Object):void
		{
			var insertedItems:Array = _collectionToChangeItems[collection].insertItems;
			var updatedItems:Array = _collectionToChangeItems[collection].updateItems;
			
			for each (var item:Object in items)
			{
				if(item is PropertyChangeEvent)
					item = item.source;
				
				if (insertedItems.indexOf(item) == -1 && updatedItems.indexOf(item) == -1)
					updatedItems.push(item);
			}
		}
		
		/**
		 * Insert new values to deleteItems array
		 * @param items the list item want to add to deleteItems array.
		 * @param collection the collection have data update. 
		 * Use as the key on Dictionary to find deleteItems array
		 * 
		 */
		private function deleteItems(items:Array, collection:Object):void
		{
			var deletedItems:Array = _collectionToChangeItems[collection].deleteItems;
			var insertedItems:Array = _collectionToChangeItems[collection].insertItems;
			var updatedItems:Array = _collectionToChangeItems[collection].updateItems;
			
			for each (var item:Object in items)
			{
				if(item is PropertyChangeEvent)
					item = item.source;
				
				var indexInUpdatedItems:int = updatedItems.indexOf(item); 
				if (indexInUpdatedItems != -1)
				{
					updatedItems.splice(indexInUpdatedItems,1);
				}
					
				var indexInInsertedItems:int = insertedItems.indexOf(item); 
				if (indexInInsertedItems != -1)
				{
					insertedItems.splice(indexInInsertedItems,1);
				}
				else
				{
					deletedItems.push(item);
				}
			}
		}
		
		private static var _savingData:Dictionary = new Dictionary(true);
		private static var _savingCollection:Dictionary = new Dictionary(true);
		
		/**
		 * Save data to server
		 * @param collection the collection have data changes. 
		 * Use as the key on Dictionary to find data use to save
		 * 
		 */
		private function saveData(collection:Object):void
		{
			//Nếu đang lưu dữ liệu trên chính collection này thì sẽ đợi đến khi nào save xong mới lưu
			if (_savingCollection[collection] !== undefined)
				return;
			if (!haveChanges(collection as ICollectionView))
			{
				if (_unregisterPending[collection])
				{
					unregisterCollection(collection as ICollectionView);
				}
				return;
			}
			
			//deley save data
			var timer:Timer = new Timer(200);
			timer.start();
			while (timer == true)
			{
				//do nothing
			}

			var saveItems:Array = getSaveItems(collection as ICollectionView);
			var deleteItems:Array = getDeleteItems(collection as ICollectionView);
			trace(saveItems.length);
			trace(deleteItems.length);
			var service:ActiveService = _services[collection];
			
			if (saveItems != null && saveItems.length > 0)
			{
				_savingCollection[collection] = true;
				var r:CallResponder = service.batchSave(saveItems,null,null,_attributes[collection]);
				_savingData[r] = saveItems;
				r.addEventListener(ResultEvent.RESULT, function(e:ResultEvent):void
				{
					var items:Array = _savingData[e.target];
					delete _savingCollection[collection];
					delete _savingData[e.target];
					
					saveData(collection);
				});
				
				r.addEventListener(FaultEvent.FAULT, function(e:FaultEvent):void
				{
					var items:Array = _savingData[e.target];
					delete _savingData[e.target];
					delete _savingCollection[collection];

					saveData(collection);
				});
			}
			if (deleteItems != null && deleteItems.length > 0)
				service.batchRemove(deleteItems);
			
			resetCollectionChange(collection as ICollectionView);
			return;
		}
		
		private function collection_collectionChangeHandler(event:Event):void
		{
			var ce:CollectionEvent = event as CollectionEvent;
			
			if(_collectionToChangeItems[ce.currentTarget].paused)
				return;
			
			if (ce == null || _collectionToChangeItems[ce.currentTarget] == undefined)
			{
				return;
			}
			
			var items:Array;
			if (ce.kind == CollectionEventKind.ADD || ce.kind == CE_KIND_ADD_ITEM)
			{
				this.insertItems(ce.items,ce.currentTarget);
			}
			else if (ce.kind == CollectionEventKind.UPDATE)
			{
				this.updateItems(ce.items,ce.currentTarget);
			}
			else if (ce.kind == CollectionEventKind.REMOVE)
			{
				this.deleteItems(ce.items,ce.currentTarget);
			}
			else if (ce.kind == CollectionEventKind.RESET ||
				ce.kind == CollectionEventKind.REFRESH)
			{
				delete _collectionToChangeItems[ce.currentTarget];
				resetCollectionChange(ce.currentTarget);
			}
			else if (ce.kind == CollectionEventKind.REPLACE)
			{
				var delItems:Array = _collectionToChangeItems[ce.currentTarget].deleteItems;
				for each (var item:Object in ce.items)
				{
					if(item is PropertyChangeEvent)
					{
						var oldItem:Object = PropertyChangeEvent(item).oldValue;
						var newItem:Object = PropertyChangeEvent(item).newValue;
						
						this.deleteItems([oldItem], ce.currentTarget);
						this.insertItems([newItem], ce.currentTarget);
					}
					else					
					{
						this.insertItems([item],ce.currentTarget);
					}
				}
			}
			
			if (isSaveAutomationOn(ce.currentTarget as ICollectionView))
			{
				saveData(ce.currentTarget);
			}
		}
		
		public static const CE_KIND_ADD_ITEM:String = "addItem";
	}
}