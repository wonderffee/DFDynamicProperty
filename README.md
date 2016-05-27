# DFDynamicProperty
Add new property for Objective-c's class without changing origin class's code, support reflection, special for JSPatch. 

It's very helpful when you want to add a new property with JSPatch, to the iOS Project that integrate MJExtension or JSONModel.

A demo of JSPatch patch file:
```js
require('DFDynamicProperty, NSString');

defineClass('ViewController', {
viewDidLoad: function() {
    DFDynamicProperty.addStringProperty_ForClass("markerImage", "SampleModel");
    DFDynamicProperty.addObjectProperty_ForClass_withPropertyClass("homeTeam", "SampleModel", "NSString");
    DFDynamicProperty.addCommonProperty_ForClass_withAttri_withPropertyClass_withCustomEncodeType("information", "SampleModel", "copy,nonatomic", NSString.class(), null);

    
    self.ORIGviewDidLoad();
    
    console.log("markerImage is " + self.modelData().markerImage().toJS());
    console.log("homeTeam is " + self.modelData().homeTeam().toJS());
    console.log("information is " + self.modelData().information().toJS());
},

});
```
