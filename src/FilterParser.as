import fl.controls.Slider;
import fl.events.ScrollEvent;

//setup target
var group:Vector.<DisplayObject>=new Vector.<DisplayObject>();
group.push(one);
group.push(two);
group.push(three);
group.push(four);
group.push(five);
group.push(six);

//add the holder
var holder:Sprite=new Sprite();
var maske:Sprite=new Sprite();
maske.graphics.beginFill(0);
maske.graphics.drawRect(600+10, 25, 185, 300);
maske.graphics.endFill();
holder.mask=maske;
holder.x=600+10;
holder.y=25;
addChild(holder);

//setup the scroll bar
bar.minScrollPosition=0;
bar.maxScrollPosition=holder.height-300;
bar.addEventListener(ScrollEvent.SCROLL, scrollParameters);


//video
var yesVideo:Boolean=false;
var video:Video=new Video();
var camera:Camera=Camera.getCamera();
camera.setMode(600, 300, 20, true);
video.x=0;
video.y=25;
video.width=600;
video.height=300;
addChild(video);
videobutton.addEventListener(MouseEvent.CLICK, swapVideo);

//load a filter
var loader:URLLoader = new URLLoader();
loader.dataFormat=URLLoaderDataFormat.BINARY;
loader.addEventListener(Event.COMPLETE, onLoadComplete);
loader.load(new URLRequest("wave.pbj"));

//loading new files
var fr:FileReference;
loadbutton.addEventListener(MouseEvent.CLICK, loadFilter);

//shader variables
var shader:Shader;
var shaderFilter:ShaderFilter;


function onLoadComplete(event:Event):void {
	shader = new Shader();
	shader.byteCode=loader.data;
	reset();
}
function reset():void {
	for (var n:int=holder.numChildren-1; n>=0; n--) {
		holder.removeChildAt(n);
	}
	n=0;
	for (var p:String in shader.data) {
		if (shader.data[p] is ShaderParameter) {
			var par:ShaderParameter=shader.data[p] as ShaderParameter;
			var shaderParameterEditor:ShaderParameterEditor=new ShaderParameterEditor(shader,par);
			shaderParameterEditor.y=n;
			shaderParameterEditor.addEventListener("parameterChange", resetShaderFilter);
			shaderParameterEditor.addEventListener(Event.REMOVED_FROM_STAGE, disposeParameter);
			holder.addChild(shaderParameterEditor);
			n+=shaderParameterEditor.realheight;
		}
	}
	holder.y=25;
	bar.scrollPosition=0;
	bar.maxScrollPosition=n-300;
	resetShaderFilter();
}

function resetShaderFilter(...rest):void {
	shaderFilter=new ShaderFilter(shader);
	applyFilter(shaderFilter);
}

function applyFilter(filter:BitmapFilter):void {
	for (var n:int=0; n<group.length; n++) {
		if (! yesVideo) {
			group[n].filters=[filter];
		} else {
			group[n].filters=[];
		}
	}
	if (yesVideo) {
		video.filters=[filter];
	} else {
		video.filters=[];
	}
}

function disposeParameter(event:Event):void {
	event.target.removeEventListener("parameterChange", resetShaderFilter);
	event.target.removeEventListener(Event.REMOVED_FROM_STAGE, disposeParameter);
}

function scrollParameters(event:ScrollEvent):void {
	holder.y=25-bar.scrollPosition;
}

function loadFilter(event:MouseEvent):void {
	fr=new FileReference();
	fr.addEventListener(Event.SELECT, fileselecter);
	fr.addEventListener(Event.CANCEL, filecanceler);
	fr.browse(getTypes());
}

function fileselecter(event:Event):void {
	event.target.addEventListener(Event.COMPLETE,filecomplete);
	fr.load();
}

function filecomplete(event:Event):void {
	filtername.text=fr.name.substr(0,fr.name.indexOf("."));
	shader = new Shader();
	shader.byteCode=fr.data;
	reset();
}

function filecanceler(event:Event):void {
	fr.cancel();
}

function getTypes():Array {
	var pbj:FileFilter=new FileFilter("Pbj *.pbj ","*.pbj");
	var allTypes:Array=[pbj];
	return allTypes;
}

function swapVideo(event:MouseEvent):void {
	var n:int;
	yesVideo=! yesVideo;
	if (yesVideo) {
		for (n=0; n<group.length; n++) {
			group[n].visible=false;
		}
		video.visible=true;
		video.attachCamera(camera);
		resetShaderFilter();
		videobutton.label="Images";
	} else {
		video.attachCamera(null);
		removeChild(video);
		video=null;
		video=new Video();
		video.x=0;
		video.y=25;
		video.width=600;
		video.height=300;
		addChild(video);
		resetShaderFilter();
		video.visible=false;
		for (n=0; n<group.length; n++) {
			group[n].visible=true;
		}
		videobutton.label="Video";
	}
}