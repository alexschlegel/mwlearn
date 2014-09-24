/**
 * class for conducting experiments in a web browser
 * @param {string|HTMLElement} [container=document.body] the container element
 *     for the experiment
 * @param {Object} [param={}] an array of optional parameters
 * @constructor
 */
JStim = function(container,param) {
	var _exp = this;
	var _data = {};

	var _param = param;

	var _background;

	this.container = container || document.body;
	this.paper = Raphael(this.container,  "100%", "100%");

	/**
	 * initialize the experiment
	 * @return {Object} this
	 */
	this.Initialize = function () {
		var col = _param.background || {r:128, g:128, b:128};
		_background = new this.Rectangle(col,0,0,this.width(),this.height());
		_data.background = _background.col.rgb();//***

		return this;
	};

	/**
	 * get the width of the experiment window
	 * @return {number} the experiment window width
	 */
	this.width = function(){
		return this.paper.canvas.offsetWidth;
	};
	/**
	 * get the height of the experiment window
	 * @return {number} the experiment window height
	 */
	this.height = function(){
		return this.paper.canvas.offsetHeight;
	};

	/**
	 * class for working with color values
	 * @param {Object|string} col Color, RGB array, or hex color string
	 * @constructor
	 */
	this.Color = function(col){
		var _rgb = {r:0, g:0, b:0};
		var _hex = '';

		/**
		 * set the color value.
		 * @param {string|Object} col a color value (RGB array or hex string)
		 */
		this.set = function(col){
			//Color object
			if(col instanceof _exp.Color){
				_rgb = col.rgb();
				_hex = col.hex();
			//RGB array
			}else{if(isRGB(col)){
				_rgb = col;
				_hex = rgb2hex(_rgb);
			//hex string
			}else{
				_hex = col;
				_rgb = hex2rgb(_hex);

				if(!_rgb){
					throw "Invalid color.";
				}
			}
		}};

		/**
		 * is col an RGB array?
		 * @param {Object|string} col the color
		 * @return {boolean} true if the color is an RGB array
		 */
		function isRGB(col){
			return (typeof col == "object") && ("r" in col) && ("g" in col) && ("b" in col);
		}
		/**
		 * is col a hex string?
		 * @param {Object|string} col the color
		 * @return {Object|boolean} the RGB array version of col, or false
		 */
		function isHex(col){
			if(typeof col == "string"){
				var hex = hex2rgb(col);
				return hex ? hex : false;
			}else{
				return false;
			}
		}

		/**
		 * convert an integer (0-255) to a two-digit hex string
		 * @param {number} x an integer from 0 to 255
		 * @return {string} the hex version of x
		 */
		function int2hex(x){
			var hex = x.toString(16);
			return hex.length == 1 ? "0" + hex : hex;
		}
		/**
		 * convert an RGB array to a hex string
		 * @param {Object} rgb an RGB array
		 * @return {string} the hex string version of rgb
		 */
		function rgb2hex(rgb){
			return "#" + int2hex(rgb.r) + int2hex(rgb.g) + int2hex(rgb.b);
		}
		/**
		 * convert a hex string to an RGB array
		 * @param {string} hex the hex string
		 * @return {Object} the RGB version of hex
		 */
		function hex2rgb(hex){
			var re = /#([\da-f]{2})([\da-f]{2})([\da-f]{2})/ig;
			var res = re.exec(hex);
			if(res){
				return {
					"r": parseInt(res[1], 16),
					"g": parseInt(res[2], 16),
					"b": parseInt(res[3], 16)
				};
			}else{
				return null;
			}
		}

		/**
		 * get the RGB array value of the color
		 * @return {Object} an RGB array
		 */
		this.rgb = function(){
			return _rgb;
		};
		/**
		 * get the hex string value of the color
		 * @return {string} a hex color string
		 */
		this.hex = function(){
			return _hex;
		};

		this.set(col);
	};

	/**
	 * generic class for stimuli
	 * @constructor
	 */
	this.Stimulus = {
		_stim: this,

		_width: 0,
		/**
		 * get or set the width of the stimulus
		 * @param {number} [W=<get>] the new width
		 * @return {number} the stimulus width
		 */
		width: function (W) {
			if(W){_width = W}
			return _width;
		},

		_height: 0,
		/**
		 * get or set the height of the stimulus
		 * @param {number} [H=<get>] the new height
		 * @return {number} the stimulus height
		 */
		height: function (H) {
			if(H){_height = H}
			return _height;
		},

		/**
		 * class for working with positions
		 * @param {Object} [pos] a Position or position array
		 * @constructor
		 */
		Position: function(pos) {
			var _X = 0;
			var _Y = 0;
			var _L = 0;
			var _T = 0;

			/**
			 * convert from X to left
			 * @param {number} X the X coordinate
			 * @return {number} the corresponding left coordinate
			 */
			function X2L(X) {
				return X + (_exp.width() - this._stim.width())/2;
			}
			/**
			 * convert from Y to top
			 * @param {number} Y the Y coordinate
			 * @return {number} the corresponding top coordinate
			 */
			function Y2T(Y) {
				return Y + (_exp.height() - this._stim.height())/2;
			}
			/**
			 * convert from left to X
			 * @param {number} L the left coordinate
			 * @return {number} the corresponding X coordinate
			 */
			function L2X(L) {
				return L - (_exp.width() - _stim.width())/2;
			}
			/**
			 * convert from top to Y
			 * @param {number} T the top coordinate
			 * @return {number} the corresponding Y coordinate
			 */
			function T2Y(T) {
				return T - (_exp.height() - _stim.height())/2;
			}

			/**
			 * set the position
			 * @param {Object} pos a Position or position array
			 * @return {Object} this
			 */
			this.set = function (pos) {
				//Position object
				if(pos instanceof _stim.Position){
					this.setXY(pos.X(), pos.Y());
				//position array with X and Y
				}else{if((typeof pos == "object") && ("X" in pos) && ("Y" in pos)){
					this.setXY(pos.X, pos.Y);
				//position array with L and T
				}else{if((typeof pos == "object") && ("L" in pos) && ("T" in pos)){
					this.setLT(pos.L, pos.T);
				}else{if(pos !== undefined){
					throw "Invalid position."
				}}}}

				return this;
			};
			/**
			 * set the position by (X,Y) coordinates
			 * @param {number} [X=old value] the new X coordinate
			 * @param {number} [Y=old value] the new Y coordinate
			 * @return {Object} this
			 */
			this.setXY = function (X,Y) {
				_X = X || _X;
				_Y = Y || _Y;
				_L = X2L(_X);
				_T = Y2T(_Y);

				return this;
			};
			/**
			 * set the position by (L,T) coordinates
			 * @param {number} [L=old value] the new left coordinate
			 * @param {number} [T=old value] the new top coordinate
			 * @return {Object} this
			 */
			this.setLT = function (L,T) {
				_L = L || _L;
				_T = T || _T;
				_X = L2X(_L);
				_Y = T2Y(_T);

				return this;
			};

			/**
			 * get the position's X coordinate
			 * @return {number} the X coordinate of the position
			 */
			this.X = function(){
				return _X;
			};
			/**
			 * get the position's Y coordinate
			 * @return {number} the Y coordinate of the position
			 */
			this.Y = function(){
				return _Y;
			};
			/**
			 * get the position's left coordinate
			 * @return {number} the left coordinate of the position
			 */
			this.L = function(){
				return _L;
			};
			/**
			 * get the position's top coordinate
			 * @return {number} the top coordinate of the position
			 */
			this.T = function(){
				return _T;
			};

		}
	};
	//this.Stimulus.pos = new this.Stimulus.Position();

	/**
	 * a rectangle stimulus
	 * @param {Object|string} col the rectangle color
	 * @param {number} X the X position of the rectangle
	 * @param {number} Y the Y position of the rectangle
	 * @param {number} W the rectangle width
	 * @param {number} H the rectangle height
	 * @constructor
	 */
	this.Rectangle = function(col,X,Y,W,H){
		this.a = 1;

		for(var x in this){
			alert(x);
		}

		//set the size
		this.width(W);
		this.height(H);

		//set the position
		this.pos.setXY(X,Y);

		var _object = _exp.paper.rect(this.pos.L(),this.pos.T(),W,H);

		//set the color
		this.color = new _exp.Color(col);

		_object.attr("fill", col.hex());
		_object.attr("stroke", col.hex());//***
	};
	this.Rectangle.prototype = this.Stimulus;

	this.Initialize();
};
