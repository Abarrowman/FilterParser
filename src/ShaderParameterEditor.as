package {
	import fl.controls.Label;
	import fl.controls.Slider;
	import fl.controls.CheckBox;
	import fl.controls.NumericStepper;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shader;
	import flash.display.ShaderParameter;
	import flash.display.ShaderParameterType;
	import flash.events.Event;
	public class ShaderParameterEditor extends Sprite {
		private var shader:Shader;
		private var parameter:ShaderParameter;
		private var label:Label;
		private var boxes:Vector.<CheckBox>;
		private var sliders:Vector.<Slider>;
		private var steppers:Vector.<NumericStepper>;
		private var lowestY:int=0;
		public function ShaderParameterEditor(affectedShader:Shader, affectedParameter:ShaderParameter) {
			//stores data
			shader=affectedShader;
			parameter=affectedParameter;
			//build vectors
			sliders=new Vector.<Slider>();
			steppers=new Vector.<NumericStepper>();
			boxes=new Vector.<CheckBox>();
			//the label
			label=new Label();
			label.text=parameter.name;
			addChild(label);
			lowestY+=22;
			//What type of parameter is this?
			switch (parameter.type) {
				case ShaderParameterType.MATRIX4X4 :
					createNumber(15);
					createNumber(14);
					createNumber(13);
					createNumber(12);
					createNumber(11);
					createNumber(10);
					createNumber(9);
				case ShaderParameterType.MATRIX3X3 :
					createNumber(8);
					createNumber(7);
					createNumber(6);
					createNumber(5);
					createNumber(4);
				case ShaderParameterType.MATRIX2X2 :
				case ShaderParameterType.FLOAT4 :
					createNumber(3);
				case ShaderParameterType.FLOAT3 :
					createNumber(2);
				case ShaderParameterType.FLOAT2 :
					createNumber(1);
				case ShaderParameterType.FLOAT :
					createNumber(0);
					break;
				case ShaderParameterType.INT4 :
					createNumber(3, true);
				case ShaderParameterType.INT3 :
					createNumber(2, true);
				case ShaderParameterType.INT2 :
					createNumber(1, true);
				case ShaderParameterType.INT :
					createNumber(0, true);
					break;
				case ShaderParameterType.BOOL4 :
					createBool(3);
				case ShaderParameterType.BOOL3 :
					createBool(2);
				case ShaderParameterType.BOOL2 :
					createBool(1);
				case ShaderParameterType.BOOL :
					createBool(0);
					break;
				default :
					trace("Unknown parameter type.");
					break;
			}
		}
		private function createBool(index:int):void{
			//build ui
			var box:CheckBox=new CheckBox();
			box.label="";
			//place ui
			box.y=lowestY;
			//setup events
			box.addEventListener(Event.CHANGE, changeBox);
			box.addEventListener(Event.REMOVED_FROM_STAGE, disposeBox);
			//add ui
			addChild(box);
			boxes.push(box);
			lowestY+=25;
		}
		private function createNumber(index:int, isInt:Boolean=false):void {
			//build ui
			var slider:Slider=new Slider();
			var stepper:NumericStepper=new NumericStepper();
			//setup ui
			stepper.minimum=slider.minimum=parameter.minValue[index];
			stepper.maximum=slider.maximum=parameter.maxValue[index];
			stepper.value=slider.value=parameter.defaultValue[index];
			stepper.stepSize=slider.snapInterval=(slider.maximum-slider.minimum)/40;
			if(isInt){
				slider.snapInterval=Math.round(slider.snapInterval);
				stepper.stepSize=slider.snapInterval;
			}
			slider.tickInterval=slider.snapInterval*4;
			//place ui
			slider.y=lowestY;
			stepper.y=slider.y-8;
			stepper.x=90;
			//setup events
			slider.liveDragging=true;
			slider.addEventListener(Event.CHANGE, changeSlider);
			stepper.addEventListener(Event.CHANGE, changeStepper);
			slider.addEventListener(Event.REMOVED_FROM_STAGE, disposeSlider);
			stepper.addEventListener(Event.REMOVED_FROM_STAGE, changeStepper);
			//add ui
			addChild(slider);
			addChild(stepper);
			sliders.push(slider);
			steppers.push(stepper);
			lowestY+=25;
		}

		private function changeBox(event:Event):void {
			if (event.target is CheckBox) {
				var box:CheckBox=event.target as CheckBox;
				var index:int=boxes.indexOf(box);
				if (index!=-1) {
					var oppositeIndex:int=boxes.length-1-index;
					parameter.value[oppositeIndex]=box.selected;
					dispatchEvent(new Event("parameterChange"));
				}
			}
		}

		private function changeSlider(event:Event):void {
			if (event.target is Slider) {
				var slider:Slider=event.target as Slider;
				var index:int=sliders.indexOf(slider);
				if (index!=-1) {
					var oppositeIndex:int=sliders.length-1-index;
					steppers[index].value=parameter.value[oppositeIndex]=slider.value;
					dispatchEvent(new Event("parameterChange"));
				}
			}
		}
		
		private function changeStepper(event:Event):void {
			if (event.target is NumericStepper) {
				var stepper:NumericStepper=event.target as NumericStepper;
				var index:int=steppers.indexOf(stepper);
				if (index!=-1) {
					var oppositeIndex:int=steppers.length-1-index;
					sliders[index].value=parameter.value[oppositeIndex]=stepper.value;
					dispatchEvent(new Event("parameterChange"));
				}
			}
		}

		private function disposeSlider(event:Event):void {
			event.target.removeEventListener(Event.CHANGE, changeSlider);
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, disposeSlider);
		}
		
		private function disposeStepper(event:Event):void {
			event.target.removeEventListener(Event.CHANGE, changeStepper);
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, disposeStepper);
		}
		
		private function disposeBox(event:Event):void {
			event.target.removeEventListener(Event.CHANGE, changeBox);
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, disposeBox);
		}
		public function get realheight():int{
			return lowestY;
		}
	}
}