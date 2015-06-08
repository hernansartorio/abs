/*
  krpanoJS javascript plugin example / template
*/

var krpanoplugin = function() {
  var local = this;   // save the 'this' pointer from the current plugin object

  var krpano = null;  // the krpano and plugin interface objects
  var plugin = null;

  var plugincanvas = null;    // optionally - a canvas object for graphic content
  var plugincanvascontext = null;


  // registerplugin - startup point for the plugin (required)
  // - krpanointerface = krpano interface object
  // - pluginpath = string with the krpano path of the plugin (e.g. "plugin[pluginname]")
  // - pluginobject = the plugin object itself (the same as: pluginobject = krpano.get(pluginpath) )
  local.registerplugin = function(krpanointerface, pluginpath, pluginobject) {
    krpano = krpanointerface;
    plugin = pluginobject;

    // add a from xml callable functions:
    plugin.get_x = get_x;
    plugin.get_y = get_y;
    plugin.get_width = get_width;
    plugin.get_height = get_height;
    plugin.get_scale = get_scale;
  }

  // unloadplugin - end point for the plugin (optionally)
  // - will be called from krpano when the plugin will be removed
  // - everything that was added by the plugin (objects,intervals,...) should be removed here
  local.unloadplugin = function() {
    plugin = null;
    krpano = null;
  }
  
  
  // Plugin functions 
  
  function get_x(destination, name, origin) {
    if (typeof(origin) === 'undefined') origin = 'left';
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

  function get_y(destination, name, origin) {
    if (typeof(origin) === 'undefined') origin = 'top';
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

  function get_width(destination, name) {
    var layer = krpano.get('layer[' + name + ']');
    var width = abs_width(layer);
    krpano.set(destination, width);
  }  

  function get_height(destination, name) {
    var layer = krpano.get('layer[' + name + ']');
    var height = abs_height(layer);
    krpano.set(destination, height);
  }
  
  function get_scale(destination, name) {
    var layer = krpano.get('layer[' + name + ']');
    krpano.set(destination, abs_scale(layer));    
  }

  // Private recursive functions
  
  function abs_scale(layer) {
    var parent = false;
    if (layer.parent) {
      parent = krpano.get('layer[' + layer.parent + ']');
      return layer.scale * abs_scale(parent) / (parent.scalechildren ? 1 : parent.scale);
    }
    return layer.scale;
  }

  function abs_width(layer) {
    return layer.pixelwidth / layer.scale * abs_scale(layer);
  }

  function abs_height(layer) {
    return layer.pixelheight / layer.scale * abs_scale(layer);
  }

  function abs_x(layer) {
    var left_values = ['lefttop', 'left', 'leftbottom'];
    var center_values = ['top', 'center', 'bottom'];
    var right_values = ['righttop', 'right', 'rightbottom'];
    var parent_scale = 1;
    var parent_width = Number(krpano.get('stagewidth'));

    if (layer.parent) {
      var parent = krpano.get('layer[' + layer.parent + ']');
      parent_width = abs_width(parent);
      parent_scale = abs_scale(parent) / (parent.scalechildren ? 1 : parent.scale);
    }
      
    if (!layer.align) layer.align = 'lefttop';
    if (!layer.edge) layer.edge = layer.align;

    var x = layer.x;

    if (left_values.contains(layer.align)) {
      x = x * parent_scale;
    }
    if (center_values.contains(layer.align)) {
      x = parent_width / 2 + x * parent_scale;
    }
    if (right_values.contains(layer.align)) {
      x = parent_width - x * parent_scale;
    }
    
    if (center_values.contains(layer.edge)) {
      x = x - abs_width(layer) / 2;
    }
    if (right_values.contains(layer.edge)) {
      x = x - abs_width(layer);
    }
    
    x = x + Number(layer.ox) * parent_scale;
    x = Math.round(x);
    if (parent) {
      return x + abs_x(parent);
    } else
      return x;
  }

  function abs_y(layer) {
    var top_values = ['lefttop', 'top', 'righttop'];
    var center_values = ['left', 'center', 'right'];
    var bottom_values = ['leftbottom', 'bottom', 'rightbottom'];
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

    if (top_values.contains(layer.align)) {
      y = Number(layer.y) * parent_scale;
    }
    if (center_values.contains(layer.align)) {
      y = parent_height / 2 + Number(layer.y) * parent_scale;
    }
    if (bottom_values.contains(layer.align)) {
      y = parent_height - Number(layer.y) * parent_scale;
    }
    
    if (center_values.contains(layer.edge)) {
      y = y - abs_height(layer) / 2;
    }
    if (bottom_values.contains(layer.edge)) {
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

  Array.prototype.contains = function(needle) {
    for (i in this) {
      if (this[i] == needle) {
        return true;
      }
    }
    return false;
  }

};