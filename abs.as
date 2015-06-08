/*
  krpano as3 plugin example / template
  for mxmlc (.as)
*/

package {
  import flash.display.*;
  import flash.text.*;
  import flash.events.*;
  import flash.utils.*;
  import flash.system.*;

  [SWF(width="400", height="300", backgroundColor="#000000")]
  public class abs extends Sprite {
    public var krpano : Object = null;
    public var plugin : Object = null;

    public function abs() {
      if (stage == null) {
        // startup when loaded inside krpano
        this.addEventListener(Event.ADDED_TO_STAGE, versioncheck);
      } else {
        // direct startup - show plugin version info
        stage.scaleMode = "noScale";
        stage.align = "TL";

        var txt:TextField = new TextField();
        txt.defaultTextFormat = new TextFormat("_sans",14,0xFFFFFF,false,false,false,null,null,"center");
        txt.autoSize = "center";
        txt.htmlText = "krpano\n\nabs plugin";
        addChild(txt);

        var resizefu:Function = function(event:Event=null):void {
          txt.x = (stage.stageWidth  - txt.width )/2;
          txt.y = (stage.stageHeight - txt.height)/2;
        }

        stage.addEventListener(Event.RESIZE, resizefu);

        resizefu();
      }
    }

    private function versioncheck(evt:Event):void {
      // compatibility check of the krpano version by using the old plugin interface:
      // - the "version" must be at least "1.0.8.14"
      // - and the "build" must be "2011-05-10" or greater
      this.removeEventListener(Event.ADDED_TO_STAGE, versioncheck);

      var oldkrpanointerface:Object = (getDefinitionByName("krpano_as3_interface") as Class)["getInstance"]();

      if (oldkrpanointerface.get("version") < "1.0.8.14" || oldkrpanointerface.get("build") < "2011-05-10") {
        oldkrpanointerface.trace(3, "abs plugin - too old krpano viewer version (min. 1.0.8.14)");
      }
    }

    // registerplugin
    // - the start for the plugin
    // - this function will be called from krpano when the plugin will be loaded
    public function registerplugin(krpanointerface:Object, pluginfullpath:String, pluginobject:Object):void {
      // get the krpano interface and the plugin object
      krpano = krpanointerface;
      plugin = pluginobject;

      // add a from xml callable functions:
      plugin.get_x = get_x;
      plugin.get_y = get_y;
      plugin.get_width = get_width;
      plugin.get_height = get_height;
      plugin.get_scale = get_scale;
    }

    // unloadplugin
    // - the end for the plugin
    // - this function will be called from krpano when the plugin will be removed
    public function unloadplugin():void {
      plugin = null;
      krpano = null;
    }


  // Plugin functions 
    
    private function get_x(destination:String, name:String, origin:String = 'left'):void {
      var layer = krpano.get('layer[' + name + ']');
      var x = abs_x(layer);
      if (origin != 'left') {
        var width = abs_width(layer);    
        if (origin == 'center') {
          x = Math.round(x + width / 2);
        } else if (origin == 'right') {
          x = Math.round(x + width);
        }
      }
      krpano.set(destination, x);
    }
    private function get_y(destination:String, name:String, origin:String = 'top'):void {
      var layer = krpano.get('layer[' + name + ']');
      var y = abs_y(layer);
      if (origin != 'top') {
        var height = abs_height(layer);    
        if (origin == 'center') {
          y = Math.round(y + height / 2);
        } else if (origin == 'bottom') {
          y = Math.round(y + height);
        }
      }
      krpano.set(destination, y);
    }

    private function get_width(destination:String, name:String):void {
      var layer = krpano.get('layer[' + name + ']');
      var width = abs_width(layer);
      krpano.set(destination, width);
    }  

    private function get_height(destination:String, name:String):void {
      var layer = krpano.get('layer[' + name + ']');
      var height = abs_height(layer);
      krpano.set(destination, height);
    }

    private function get_scale(destination:String, name:String):void {
      var layer = krpano.get('layer[' + name + ']');
      krpano.set(destination, abs_scale(layer));    
    }
    
    // Private recursive functions
    
    private function abs_scale(layer:Object) {
      if (layer.parent) {
        var parent = krpano.get('layer[' + layer.parent + ']');
        return layer.scale * abs_scale(parent) / (parent.scalechildren ? 1 : parent.scale);
      }
      return layer.scale;
    }

    private function abs_width(layer:Object) {
      return layer.pixelwidth / layer.scale * abs_scale(layer);
    }

    private function abs_height(layer:Object) {
      return layer.pixelheight / layer.scale * abs_scale(layer);
    }

    private function abs_x(layer:Object) {
      var left_values:Array = ['lefttop', 'left', 'leftbottom'];
      var center_values:Array = ['top', 'center', 'bottom'];
      var right_values:Array = ['righttop', 'right', 'rightbottom'];
      var parent_scale = 1;
      var parent_width = Number(krpano.get('stagewidth'));

      if (layer.parent) {
        var parent = krpano.get('layer[' + layer.parent + ']');
        parent_width = abs_width(parent);
        parent_scale = abs_scale(parent) / (parent.scalechildren ? 1 : parent.scale);
      }
        
      if (!layer.align) layer.align = 'lefttop';
      if (!layer.edge) layer.edge = layer.align;

      var x = 0;

      if (includes(left_values, layer.align)) {
        x = Number(layer.x) * parent_scale;
      }
      if (includes(center_values, layer.align)) {
        x = parent_width / 2 + Number(layer.x) * parent_scale;
      }
      if (includes(right_values, layer.align)) {
        x = parent_width - Number(layer.x) * parent_scale;
      }
      
      if (includes(center_values, layer.edge)) {
        x = x - abs_width(layer) / 2;
      }
      if (includes(right_values, layer.edge)) {
        x = x - abs_width(layer);
      }
      
      x = x + Number(layer.ox) * parent_scale;
      x = Math.round(x);
      if (parent) {
        return x + abs_x(parent);
      } else {
        return x;
      }
    }

    private function abs_y(layer:Object) {
      var top_values:Array = ['lefttop', 'top', 'righttop'];
      var center_values:Array = ['left', 'center', 'right'];
      var bottom_values:Array = ['leftbottom', 'bottom', 'rightbottom'];
      var parent_scale = 1;
      var parent_height = Number(krpano.get('stageheight'));

      if (layer.parent) {
        var parent = krpano.get('layer[' + layer.parent + ']');
        parent_height = abs_height(parent);
        parent_scale = abs_scale(parent) / (parent.scalechildren ? 1 : parent.scale);
      }
        
      if (!layer.align) layer.align = 'lefttop';
      if (!layer.edge) layer.edge = layer.align;

      var y = 0;

      if (includes(top_values, layer.align)) {
        y = Number(layer.y) * parent_scale;
      }
      if (includes(center_values, layer.align)) {
        y = parent_height / 2 + Number(layer.y) * parent_scale;
      }
      if (includes(bottom_values, layer.align)) {
        y = parent_height - Number(layer.y) * parent_scale;
      }
      
      if (includes(center_values, layer.edge)) {
        y = y - abs_height(layer) / 2;
      }
      if (includes(bottom_values, layer.edge)) {
        y = y - abs_height(layer);
      }
      
      y = y + Number(layer.oy) * parent_scale;
      y = Math.round(y);
      if (parent) {
        return y + abs_y(parent);
      } else {
        return y;
      }
    }
    
    private function includes(array:Array, element:Object) {
      return array.indexOf(element) >= 0;
    }

  }
}