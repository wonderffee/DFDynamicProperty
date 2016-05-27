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