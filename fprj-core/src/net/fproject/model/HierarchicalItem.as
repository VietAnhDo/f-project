///////////////////////////////////////////////////////////////////////////////
//
// Licensed Source Code - Property of ProjectKit
//
// Copyright © 2013 ProjectKit. All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
package net.fproject.model
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	import net.fproject.collection.AdvancedArrayCollection;
	
	
	/**
	 * A hierarchical object, that is base class for all hierarchical model classes
	 */
	public class HierarchicalItem extends LocalUID
	{
		/**
		 * Constructor 
		 * 
		 */
		public function HierarchicalItem()
		{
			_children = new AdvancedArrayCollection();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------    
		
		//----------------------------------
		//  parent
		//----------------------------------
		
		/**
		 * Storage for the parent property.
		 */
		protected var _parent:HierarchicalItem;
		
		[Transient]
		[Bindable("propertyChange")]
		/**
		 * The parent for this element
		 */
		public function get parent():HierarchicalItem
		{
			return _parent;
		}
		
		/**
		 * @private
		 */
		public function set parent(value:HierarchicalItem):void
		{
			setParent(value);
		}
		
		/**
		 * Set the parent node and/or changing hierachical layout 
		 * @param newParent the new parent
		 * @param newIndex the new index of the item in the children list of the new parent
		 * @return <code>true</code> if the new parent is set, <code>false</code> if nothing was set
		 */
		public function setParent(newParent:HierarchicalItem, newIndex:int=-1, firePropertyChange:Boolean=true):Boolean
		{
			if (_parent !== newParent)
			{
				var oldParent:HierarchicalItem = _parent;
				if (oldParent != null)
					oldParent.removeChild(this);
				
				_parent = newParent;
				
				if (_parent != null)
				{
					_parent.addChild(this, newIndex);
					outlineLevel = _parent.outlineLevel + 1;
				}
				else
				{
					outlineLevel = 0;
				}
				
				var b:Boolean = true;
			}
			else
				b = false;
			
			if(firePropertyChange)
				dispatchParentChanged(oldParent, _parent);
			
			return b;
		}
		
		//----------------------------------
		//  children
		//----------------------------------
		
		/**
		 * Storage for the children property
		 */
		protected var _children:AdvancedArrayCollection;
		
		[Transient]
		[Bindable("propertyChange")]
		/**
		 * The children of this element 
		 */
		public function get children():ArrayCollection
		{
			return _children;
		}
		
		//----------------------------------
		//  allChildren
		//----------------------------------
		
		[Transient]
		/**
		 * The children and subchildren of this element. 
		 */    
		public function get allChildren():Array
		{
			var array:Array = [];
			flatten(children, array);
			return array;
		}
		
		/**
		 * Create an array that contains all tree-element of a hierachical list.
		 * @param hierachicalList the hierachical list
		 * @param result the output result array
		 */
		public static function flatten(hierachicalList:IList, result:Array):void
		{
			for each (var node:HierarchicalItem in hierachicalList)
			{
				result.push(node);
				if (node.children != null)
				{
					flatten(node.children, result);
				}
			}
		}
		
		public function hasChild(child:HierarchicalItem, recursive:Boolean=false):Boolean
		{
			if(_children != null)
			{
				if(_children.getItemIndex(child) != -1)
					return true;
				if(recursive)
				{
					for each(var i:HierarchicalItem in _children)
					{
						if(i.hasChild(child, true))
							return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * Add a child to children collection.
		 */
		public function addChild(element:HierarchicalItem, index:int=-1, 
								 replaceIfExist:Boolean=true, updateParent:Boolean=false,
								 firePropertyChange:Boolean=true):void
		{
			var i:int = _children.getItemIndex(element);
			if(i != -1)
			{
				_children.setItemAt(element, i);
			}
			else
			{
				if(index == -1)
					_children.addItem(element); 
				else
					_children.addItemAt(element, index)
			}
			
			if(updateParent && element.parent !== this)
			{
				var oldParent:HierarchicalItem = element.parent;
				if (oldParent != null)
					oldParent.removeChild(element);
				element._parent = this;
				if(firePropertyChange)
					element.dispatchParentChanged(oldParent, this);
			}
			
			dispatchChildrenChanged();
		}
		
		/**
		 * Add an multiple childs to children collection.
		 * @param children an array of childs or a IList instance that contains childs
		 */
		public function addChildren(children:Object, index:int=-1,
									replaceIfExist:Boolean=true, updateParent:Boolean=false,
									firePropertyChange:Boolean=true):void
		{
			if(children is Array)
				var list:IList = new ArrayList(children as Array);
			else
				list = IList(children);
				
			for(var i:int=0; i<list.length; i++)
			{
				var item:Object = list.getItemAt(i);
				var idx:int = _children.getItemIndex(item);
				
				if(idx != -1)
					_children.setItemAt(item, idx);
				else if(index == -1)
					_children.addItem(item); 
				else
					_children.addItemAt(item, index);
				
				if(updateParent && item is HierarchicalItem)
				{
					var element:HierarchicalItem = item as HierarchicalItem;
					if(element._parent !== this)
					{
						var oldParent:HierarchicalItem = element.parent;
						if (oldParent != null)
							oldParent.removeChild(element);
						element._parent = this;
						if(firePropertyChange)
							element.dispatchParentChanged(oldParent, this);
					}
				}						
			}
			if(list.length > 0)
				dispatchChildrenChanged();
		}
		
		/**
		 * Set/reset the <code>source</code> property for <code>children</code> collection.
		 * 
		 * This method helps improve performance especially when you want to add a large number of children.
		 * 
		 * @param source the source array.
		 * 
		 */
		public function setChildren(source:Array):void
		{
			for each(var item:HierarchicalItem in source)
			{
				item._parent = this;
			}
			_children.source = source;
		}
		
		/**
		 * Called when a child is removed.
		 */
		public function removeChild(element:HierarchicalItem):void
		{
			var index:int = _children.getItemIndex(element);
			if (index == -1)
				return;
			_children.removeItemAt(index);
			dispatchChildrenChanged();
		}
		
		/**
		 * @private
		 */
		private function dispatchChildrenChanged():void
		{
			dispatchChangeEvent("children", null, children);   
		}
		
		/**
		 * @private
		 */
		private function dispatchParentChanged(oldParent:HierarchicalItem=null, newParent:HierarchicalItem=null):void
		{
			if(newParent == null)
				newParent = _parent;
			dispatchChangeEvent("parent", oldParent, newParent);   
		}
		
		/**
		 * Indicates whether the specified element is an ancestor of this element.
		 */
		public function isAnAncestorOf(value:HierarchicalItem):Boolean
		{
			if (value == null || value.parent == this)
				return true;
			else if (value.parent == null)
				return false;
			else
				return isAnAncestorOf(value.parent);
		}
		
		[Transient]
		[Bindable("none")]
		public var lid:Number;
		
		[Transient]
		[Bindable("none")]
		public var outlineLevel:Number;
	}
}
