function Control(v, p, b, pg) {
	this.v = v;
	this.p = p;
	this.b = b;
	this.pg = pg;
	this.event = function() {}
	this.output = function(v) { return v }
    this.get = function() {
        return this.v;
    }
    this.set = function(input) {
        this.v = input;
        this.event(this.v)
    }
}

Control.prototype.draw = function(g) {}
Control.prototype.look = function() {}

var Toggle = function(v, p, b, pg) {
	Control.call(this, v, p, b, pg);
}

Toggle.prototype = Object.create(Control.prototype);

Toggle.prototype.draw = function(g) {
	if(this.pg()) {	
		//post(this.p[0], this.p[1], this.b[this.v])
		g.led(this.p[0], this.p[1], this.b[this.v]);
	}
}
	
Toggle.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(x == this.p[0] && y == this.p[1]) {
			if(z == 0) {
				var last = this.v;
				this.v = Math.abs(this.v - 1)
				this.event(this.v, last);
				
				return 1;
			}
		}
	}
}

Toggle.prototype.set = function(input) {
    this.v = input;
    this.event(this.v, null)
}

var Momentary = function(v, p, b, pg) {
	Toggle.call(this, v, p, b, pg);
}

Momentary.prototype = Object.create(Toggle.prototype);

Momentary.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(x == this.p[0] && y == this.p[1]) {
			var v = z
			this.event(v);
			this.v = v;
			
			return 1;
		}
	}
}

var Value = function(v, p, b, pg) {
	Control.call(this, v, p, b, pg);
}

Value.prototype = Object.create(Control.prototype);

Value.prototype.draw = function(g) {
	if(this.pg()) {
		var bb = this.b[0].slice();
		bb[this.v] = this.b[1];
		
		if(this.p[0].length) {
			for(var i = 0; i < this.p[0].length; i++) {
				g.led(this.p[0][i], this.p[1], bb[i]);
			}
		} 
		else {
			
			for(var i = 0; i < this.p[1].length; i++) {
				g.led(this.p[0], this.p[1][i], bb[i]);
			}
		}
	}
}

Value.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(this.p[0].length) {
			if(y == this.p[1]) {
				for(var i = 0; i < this.p[0].length; i++) {
					if(this.p[0][i] == x && z == 1) {
                        var last = this.v;
						var v = i;
						this.event(v, last);
						this.v = v;
						
						return 1;
					}
				}
			}
		}
		else {
			if(x == this.p[0]) {
				for(var i = 0; i < this.p[1].length; i++) {
					if(this.p[1][i] == y && z == 1) {
                        var last = this.v;
						var v = i;
						this.event(v, last);
						this.v = v;
						
						return 1;
					}
				}
			}
		}
	}
}

Toggle.prototype.set = function(input) {
    this.v = input;
    this.event(this.v, null)
}

var Toggles = function(v, p, b, pg) {
	Control.call(this, v, p, b, pg);
}

Toggles.prototype = Object.create(Control.prototype);

Toggles.prototype.draw = function(g) { 
	if(this.pg()) {
		var bb = this.b[0].slice();
		
		for(var i = 0; i < this.v.length; i++) {
			bb[this.v[i]] = this.b[1];
		}
		
		if(this.p[0].length) {
			for(var i = 0; i < this.p[0].length; i++) {
				g.led(this.p[0][i], this.p[1], bb[i]);
			}
		} 
		else {
			for(var i = 0; i < this.p[1].length; i++) {
				g.led(this.p[0], this.p[1][i], bb[i]);
			}
		}
	}
}

Toggles.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(this.p[0].length) {
			if(y == this.p[1]) {
				for(var i = 0; i < this.p[0].length; i++) {
					if(this.p[0][i] == x && z == 1) {
						var last = this.v.slice();
						var added = -1;
						var removed = -1;
						
						var thing = this.v.indexOf(i);
						
						if(thing == -1) {
							this.v.push(i);
							//this.v.sort(function(a, b) { return a - b; });
							
							var added = i;
						}
						else {
							this.v.splice(thing, 1);
							
							var removed = i;
						}
						
						this.event(this.v, last, added, removed);
						
						return 1;
					}
				}
			}
		}
		else {
			if(x == this.p[0]) {
				for(var i = 0; i < this.p[1].length; i++) {
					if(this.p[1][i] == y && z == 1) {
						var last = this.v.slice();
						var added = -1;
						var removed = -1;
						
						var thing = this.v.indexOf(i);
						
						if(thing == -1) {
							this.v.push(i);
							//this.v.sort(function(a, b) { return a - b; });
							
							added = i;
						}
						else {
							this.v.splice(thing, 1);
							
							removed = i;
						}
						
						this.event(this.v, last, added, removed);
						
						return 1;
					}
				}
			}
		}
	}
}

Toggles.prototype.set = function(input) {
    this.v = input;
    this.event(this.v, null, null, null)
}

var Momentaries = function(v, p, b, pg) {
	Toggles.call(this, v, p, b, pg);
}

Momentaries.prototype = Object.create(Toggles.prototype);

Momentaries.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(this.p[0].length) {
			if(y == this.p[1]) {
				for(var i = 0; i < this.p[0].length; i++) {
					if(this.p[0][i] == x) {
						var last = [];
						if(this.v) last = this.v.slice();
						var added = -1;
						var removed = -1;
						
						if(z == 1 && this.v.indexOf(i) == -1) {
							this.v.push(i);
							this.v.sort(function(a, b) { return a - b; });
							
							added = i;
						}
						else {
							this.v.splice(this.v.indexOf(i), 1);
							
							removed = i;
						}
						
						this.event(this.v, last, added, removed);
						
						return 1;
					}
				}
			}
		}
		else {
			if(x == this.p[0]) {
				for(var i = 0; i < this.p[1].length; i++) {
					if(this.p[1][i] == y && z == 1) {
						var last = this.v.slice();
						var added = -1;
						var removed = -1;
						
						if(z == 1 && this.v.indexOf(i) == -1) {
							this.v.push(i);
							this.v.sort(function(a, b) { return a - b; });
							
							added = i;
						}
						else {
							this.v.splice(this.v.indexOf(i), 1);
							
							removed = i;
						}
						
						this.event(this.v, last, added, removed);
						
						return 1;
					}
				}
			}
		}
	}
}

Momentaries.prototype.set = function(input) {
    this.v = input;
    this.event(this.v, null, null, null)
}

var Fader = function(v, p, b, pg) {
	Value.call(this, v, p, b, pg);
	
	this.pp = p[0].slice();
	this.bb = b[0];
	
	//var value = new Value(v, p, b, pg);
	this.p[0] = [];
	this.b[0] = [];
	
	for(var i = this.pp[0]; i <= this.pp[1]; i++) {
		this.p[0][i - this.pp[0]] = i;
		this.b[0][i] = this.bb;
	}
}

Fader.prototype = Object.create(Value.prototype);

Fader.prototype.draw = function(g) {
	if(this.pg()) {
		if(this.p[0].length) {
			for(var i = 0; i < this.p[0].length; i++) {
				if(i < this.v) this.b[0][i] = this.b[2];
				else this.b[0][i] = this.bb;
			}
		}
		else {
			for(var i = 0; i < this.p[1].length; i++) {
				if(i < this.v) this.b[0][i] = this.b[2];
				else this.b[0][i] = this.bb;
			}
		}
		Value.prototype.draw.call(this, g);
	}
}

var Crossfader = function(v, p, b, pg) {
	Fader.call(this, v, p, b, pg);
}

Crossfader.prototype = Object.create(Fader.prototype);

Crossfader.prototype.draw = function(g) {
	if(this.pg()) {
		if(this.p[0].length) {
			for(var i = 0; i < this.p[0].length; i++) {
				if((i > this.v && i <= Math.round(this.p[0].length - 1) / 2) || (i < this.v && i >= Math.round(this.p[0].length - 1) / 2)) this.b[0][i] = this.b[2];
				else this.b[0][i] = this.bb;
			}
		}
		else {
			for(var i = 0; i < this.p[1].length; i++) {
				if((i > this.v && i <= this.p[0].length / 2) || (i < this.v && i >= this.p[0].length / 2)) this.b[0][i] = this.b[2];
				else this.b[0][i] = this.bb;
			}
		}
		Value.prototype.draw.call(this, g);
	}
}

var Pattern = function(v, p, b, pg, f, index) {
    //v, time, r, pattern
    
	Toggle.call(this, v, p, b, pg);
	
	this.ispattern = 1;

	var time = 0;
	var r = 0;
	
	var pattern = {}
		
	var task = new Task(function() {
		if(time > 0) {
			for(t in pattern) {
				if((arguments.callee.task.iterations % time) == t) {
                    
                    //var args = JSON.parse(JSON.stringify(pattern[t]));
                    var args = [];
                    
                    for(var i = 0; i < pattern[t].length; i++) {
                        args[i] = pattern[t][i]
                    }
                    
                    post("update4", JSON.stringify(pattern[t]));
//                    
                    if(index != null) args[pattern[t].length] = index;
                    
					f.apply(null, args); //---------
				}
			}
		}
	}, this);
	task.interval = 1;
	
	this.event = function(v, last) {
		if(last == 2) { //v=0 r=0
			this.v = 0;
		}
		else if(v == 0 && last == 1) { //v=2
			this.v = 2;
		}
		
        if(this.v == 0) {
            time = 0;
			r = 0;
			pattern = {}
			task.cancel();
        }
        else if(this.v == 2) {
            time == 0 ? time = task.iterations : time = time;
			r = 0;
			task.cancel();
			task.repeat();
        }
        else if(this.v == 1) {
            r = 1;
			task.repeat();
        }
        
		this.draw(g);
	}
	
	this.store = function(h, i, j, k, v) {
		if(r) {
            post("update3", task.iterations, JSON.stringify(arguments));
            
			if(arguments.length = 5) {
                var v_copy;
                
                if(typeof v === 'object' && v !== null) {
                    v_copy = JSON.parse(JSON.stringify(v))
                } else v_copy = v;
                
                pattern[task.iterations] = [ h, i, j, k, v_copy ];
            } 
            else pattern[task.iterations] = [ h, i, j, k ];
		}
	}
    
    this.get = function() {
        return { v: this.v, time: time, pattern: pattern }
    }
    
    this.set = function(input) {
        this.v = input.v;
        time = input.time;
        pattern = input.pattern;
        
        this.event(this.v, null);
    }
}

Pattern.prototype = Object.create(Toggle.prototype);

//var Recorder = function(v, p, b, pg) {
//	Toggle.call(this, v, p, b, pg);
//    
//    this.v = [ v, 0 ];
//    
//    this.timer = function() {
//        
//    }
//}
//
//Recorder.prototype = Object.create(Toggle.prototype);
//
//Recorder.prototype.look = function(x, y, z) {
//	if(this.pg()) {
//		if(x == this.p[0] && y == this.p[1]) {
//			if(z == 0) {
//                
//				var last = this.v;
//				this.v[0] = Math.abs(this.v[0] - 1)
//                
//                this.timer()
//                
//				this.event(this.v, last);
//				
//				return 1;
//			}
//		}
//	}
//}


var Glide = function(v, p, b, pg) {
    v = [v];
    
	Toggles.call(this, v, p, b, pg);
    
    // { origin: i, dest: i, time: t }
    this.v = { draw: this.v, transform: {} }
    
    this.timer_start = 0;
    this.timer = new Task(function() {
        this.v.transform.time = (max.time - this.timer_start) / 1000;
	}, this);
	this.timer.interval = 1;
    
    this.set = function(input) {
        if(this.v.transform.dest == null) {
            this.v = {
                draw: [input],
                transform: {}
            }
            
            this.event(this.v);
        }
    }

    this.get = function() {
        return this.v.draw[0];
    }
}

Glide.prototype = Object.create(Toggles.prototype);

Glide.prototype.look = function(x, y, z) {
	if(this.pg()) {
		if(this.p[0].length) {
			if(y == this.p[1]) {
				for(var i = 0; i < this.p[0].length; i++) {
					if(this.p[0][i] == x) {
						if(z == 1) {
                            
                            if(this.v.transform.origin == null) {
                                this.v.transform = {}
                                this.v.transform.origin = i;
                                
                                this.timer.repeat();
                                this.timer_start = max.time;
                                
                                this.v.draw = [i];
                            } else if(this.v.transform.origin != null) {
                                
                                this.v.transform.dest = i;
                                this.v.draw = [this.v.transform.origin, i];
                                
                                //this.v.draw.sort(function(a, b) { return a - b; });
                            } else {
                                //this.v.draw = [i];
                            }
						}                        
						else {
                            if(this.v.transform.dest != null && i == this.v.transform.dest) { //end of glide
                                this.event(this.v);
                                
                                //this.v.transform.time = 0;
                                this.v.draw = [this.v.transform.dest];
                                
                                this.timer.cancel();
                            } else if(this.v.transform.origin != null && i == this.v.transform.origin) {          
                               
                                if(this.v.transform.dest != null) { //end of glide
                                    this.v.draw = [this.v.transform.dest]; 
                                    
                                    this.event(this.v);
                                    
                                    //this.v.transform.time = 0;
                                } else { //no glide
                                    
                                    this.event(this.v);
                                    
                                    this.v.transform.time = 0;
                                    
                                }
                                
                                
                                this.v.transform.origin = null;
                                this.timer.cancel();
                            } else if(this.v.transform.dest == null && this.v.transform.origin == null) { //remote set
                                this.v.draw = [i];
                                this.timer.cancel();
                                
                                this.event(this.v);
                                
                                this.v.transform.time = 0;
                            } else { //no output
                                
                            }
                        }
                        
						return 1;
					}
				}
			}
		}
		else { //TODO
		}
	}
}

Glide.prototype.draw = function(g) { 
	if(this.pg()) {
		var bb = this.b[0].slice();
		
		for(var i = 0; i < this.v.draw.length; i++) {
			bb[this.v.draw[i]] = this.b[1];
		}
		
		if(this.p[0].length) {
			for(var i = 0; i < this.p[0].length; i++) {
				g.led(this.p[0][i], this.p[1], bb[i]);
			}
		} 
		else {
			for(var i = 0; i < this.p[1].length; i++) {
				g.led(this.p[0], this.p[1][i], bb[i]);
			}
		}
	}
}


//------------------------------------------------------------------------------------------------------------------------

var controls = {}

var TT = 1;
var LO = 1;
var HI = 15;

var page = 0;

var locked = 0;

var g = grid.connect();

if (!Math.log2) Math.log2 = function(x) { //log2 polyfill
  return Math.log(x) * Math.LOG2E;
};

var update = function(h, i, j, v) {
	if (controls[h][i][j].v != v) {
		controls[h][i][j].event(v);
		controls[h][i][j].v = v;
	}
	
	controls[h][i][j].draw(g);
    
	redraw();
	diction_out();
	g.refresh();
}

var update2 = function(h, i, j, k, v, index) {
    
    post("update5", h, i, j, k, v, index);
    
    if(controls[h][i][j].i == index) {
        
        if(controls[h][i][j][k].v != v || (typeof v === 'object' && v !== null)) {       
            controls[h][i][j][k].event(v);
            controls[h][i][j][k].v = v;
        }
    }

    controls[h][i][j][k].draw(g);
	
	diction_out();
    g.refresh();
}

g.event = function(x, y, z) {
	for(h in controls) {
		for(i in controls[h]) {
            if(controls[h][i]) {
                for(j in controls[h][i]) {
                    if(controls[h][i] && controls[h][i][j] && controls[h][i][j].look) {
                        if(controls[h][i][j].look(x, y, z)) {
                            for(l in controls[h][i]) {
                                if(!(controls[h][i][j].ispattern) && controls[h][i][l].ispattern) {
                                    controls[h][i][l].store(h, i, j, controls[h][i][j].v);
                                }
                            }
                        }

                        if(controls[h][i][j].draw) controls[h][i][j].draw(g);
                    } else {
                        if(controls[h][i]) {
                            for(k in controls[h][i][j]) {
                                if(controls[h][i] && controls[h][i][j][k] && controls[h][i][j][k].look) {
                                    if(controls[h][i][j][k].look(x, y, z)) {
                                        if(controls[h][i]) {
                                            for(l in controls[h][i][j]) {
                                                if(!(controls[h][i][j][k].ispattern) && controls[h][i][j][l].ispattern) {
                                                    post("update2", JSON.stringify(controls[h][i][j][k].v));
                                                    controls[h][i][j][l].store(h, i, j, k, controls[h][i][j][k].v);
                                                }
                                            }
                                        }
                                    }

                                    if(controls[h][i] && controls[h][i][j][k].draw) controls[h][i][j][k].draw(g);
                                }
                            }
                        }
                    }
                }
            }
		}
	}
	
	diction_out();
	g.refresh();
}

var redraw = function() {
	g.all(0);
	for(h in controls) {
		for(i in controls[h]) {
			for(j in controls[h][i]) {
				if(controls[h][i][j].draw) controls[h][i][j].draw(g);
                else {
                    for(k in controls[h][i][j]) {
                        if(controls[h][i][j][k] && controls[h][i][j][k].draw) controls[h][i][j][k].draw(g);
                    }
                }
			}
		}
	}
}

//------------------------------------------------------------------------------------------------------------------------

var set_bang = function(line_num, key, value) {
    var active_num = controls.lines[line_num].preset.i;
    
    if(diction_bang == null) {
        var bang = { softcut: [] }
        bang.softcut[line_num] = { active: active_num, presets: [] }
        bang.softcut[line_num].presets[active_num] = {}
        bang.softcut[line_num].presets[active_num][key] = value
        diction_bang = bang;
    } else if(diction_bang.softcut && diction_bang.softcut[line_num] && diction_bang.softcut[line_num].presets && diction_bang.softcut[line_num].presets[active_num]) {
        diction_bang.softcut[line_num].presets[active_num][key] = value;
    } else if(diction_bang.softcut && diction_bang.softcut[line_num] && diction_bang.softcut[line_num].presets) {
        diction_bang.softcut[line_num].presets[active_num] = {}
        diction_bang.softcut[line_num].presets[active_num][key] = value
    } else if(diction_bang.softcut) {
        diction_bang.softcut[line_num] = { active: active_num, presets: [] }
        diction_bang.softcut[line_num].presets[active_num] = {}
        diction_bang.softcut[line_num].presets[active_num][key] = value
    }
}

var buffdate = function() {
    for(var i = 0; i < controls.lines.length; i++) {
        for(var j = 0; j < controls.lines[i].presets.length; j++) {
            controls.lines[i].presets[j].buf.set(controls.lines[i].presets[j].buf.get());
        }
    }
}

var Preset = function(n, i) {
    var me = this;
    
    
//    //         0  1  2  3  4    5     6     7  8     9    10  11 12 13 14
//    //in max: -8 -4 -2 -1 -0.5 -0.25 -0.125 0. 0.125 0.25 0.5 1  2  4  8
//    var coarse_table = [
//        [ 9, 10, 11, 12, 13 ], //fwd
//        [ 5, 4, 3, 2, 1 ] //rev
//    ]
    
	var time_counter;
    var loopsize = 0;
    this.buffer = new Buffer("&&buf_" + n % 4);
    var initial_rec = false;
    
    var timer = new Task(function() {
        loopsize += (max.time - time_counter) * (this.softcut.rate * this.softcut.rate_offset / 1000);
		time_counter = max.time;
	}, this);
	timer.interval = 1;
    
    this.i = i;
    this.n = n;
    this.r = new Toggle(0, [0, n], [0, HI], function() { return page == 0; });
    this.r.event = function(v) {
        me.softcut.rec = v;
        
        if(v == 1 && me.m.get() == 0) { //start initial rec
            initial_rec = true;
            
            loopsize = 0;
            me.softcut.loop_end = me.buffer.length() / 1000;
			me.softcut.rec_end = me.buffer.length() / 1000;
            
			set_bang(me.n, "position", 0);
			
            me.buffer.send("clear");
            
			time_counter = max.time;
            timer.repeat();
            
            me.softcut.play = 1;
            
            //buffdate();
        }
        else if(v == 0 && initial_rec) { //end initial rec
            initial_rec = false;
            
            timer.cancel();

            me.softcut.loop_end = loopsize;
			me.softcut.rec_end = loopsize;
            me.m.set(1);
            
            //buffdate();
        }
    }
	this.m = new Toggle(0, [1, n], [0, HI], function() { return page == 0; });
    this.m.event = function(v) {
        if(v == 1 && initial_rec) { //end initial rec if that's going
            initial_rec = false;
            
            timer.cancel();
            me.softcut.loop_end = loopsize;
			me.softcut.rec_end = loopsize;
        }
        
        me.softcut.play = v;
    }
	this.rev = new Toggle(0, [0, n+4], [LO, HI], function() { return page == 0; });
    this.rev.event = function(v) {
        this.v = v
        
        me.softcut.rate = (v ? -1 : 1) * Math.abs(me.softcut.rate);
    }
    this.s = new Glide(4, [[1, 2, 3, 4, 5, 6, 7], n+4], [[0, 0, 0, 0, 0, 0, 0, 0], HI], function() { return page == 0; });
    this.s.event = function(v) {
        var tmult = (1.3 + (Math.random() * 0.5));
        
        if(v.transform.time != null && v.transform.dest != null) me.softcut.rate_slew_time = v.transform.time * tmult;
        
        var rate;
        if(v.transform.dest != null) rate = v.transform.dest;
        else if(v.transform.origin != null) rate = v.transform.origin;
        
        if(rate != null) me.softcut.rate = (me.rev.get() ? -1 : 1) * Math.pow(2, (rate - 4));
        
        if(v.transform.time) {
            var delay = new Task(function() { this.softcut.rate_slew_time = 0; 
                                             diction_out();
                                            }, me);
            delay.schedule((v.transform.time + 0.01) * 1000);
        }
        
    }
    
    this.buf = new Value(n % 4, [[3, 4, 5, 6], n], [[0, 0, 0, 0], HI], function() { return page == 0; });
    this.buf.event = function(v) {
        var num = (me.n >= 4) ? v + 4 : v;
        
        me.softcut.buffer = "&&buf_" + num;
        me.buffer = new Buffer("&&buf_" + num);
        
        me.softcut.loop_start = controls.lines[num].preset.softcut.loop_start;
        me.softcut.loop_end = controls.lines[num].preset.softcut.rec_end;
        
        set_bang(me.n, "position", 0);
    }

    this.pat = new Pattern(0, [7, n], [0, LO, HI], function() { return page == 0; }, update2, i);
    
    this.softcut = {
        rec: 0,
        play: 0,
        rate: 1,
        rate_offset: 1,
        rec_level: 1,
        pre_level: 0.5,
        voice_sync: "-",
        buffer: "&&buf_" + n % 4,
        level_slew_time: 0,
        rate_slew_time: 0,
        phase_quant: "-",
        fade_time: 0.1,
		rec_start: 0,
		rec_end: 0,
        loop_start: 0,
        loop_end: 0,
        loop: 1,
        pan: 0,
        level: 1
    }
    
    this.get = function() { return {
        r: this.r.get(),
        m: this.m.get(),
        rev: this.rev.get(),
        s: this.s.get(),
        buf: this.buf.get(),
        pat: this.pat.get(),
        softcut: this.softcut
    }}
    
    this.set = function(input) {
        this.r.set(input.r);
        this.m.set(input.m);
        this.rev.set(input.rev);
        this.s.set(input.s);
        this.buf.set(input.buf);        
        this.pat.set(input.pat);
        this.softcut = JSON.parse(JSON.stringify(input.softcut));
    }
    
    this.softcut_get = function() { return this.softcut; }
    
    this.softcut_set = function(input) {
	    //this.m.set(Number(input.play == 1 && input.rec == 0));
        //this.r.set(input.rec);    
//      
        var is_neg = Number(input.rate < 0);
        this.rev.set(is_neg);
        
        var absr = Math.abs(input.rate);
        if(absr <= 4) this.s.set(Math.round(Math.log2(absr)) + 4);
        
        this.buf.set(input.buffer.split('_')[1] % 4);
        this.buffer = new Buffer(input.buffer);
        
        this.softcut = input;
    }
}

var home = new LiveAPI("this_device canonical_parent");

var Line = function(n) {
    var me = this;
    me.n = n;
    
    this.presets = [];
    
    this.preset;
    
    this.track = new LiveAPI();
    
    this.location = 0;
    
    this.track = new LiveAPI();
	this.path;
    
    this.preset_set = function(v) {
        var is_new = me.presets[v] == null
        
        if(me.presets[v]) {
            me.preset = me.presets[v];
        } else {
            me.presets[v] = new Preset(me.n, v);
            if(me.preset) me.presets[v].set(me.preset.get());
            me.preset = me.presets[v];
        }
        
        return is_new;
    }
    
    this.menu = new Value(0, [[0, 1, 2, 3, 4, 5, 6, 7], n], [[0,0,0,0,0,0,0,0], HI], function() { return page == n + 1; });
    this.menu.event = function(v, last) {
        if(me.preset_set(v)) this.b[0][v] = TT;
    }
    this.menu.event(0, 0);
//    this.menub = new Momentary(0, [14, n], [TT, HI], function() { return page < 9; });
//    this.menub.event = function(v) {
//		this.v = v;
//        this.v ? page = n + 1 : locked ? page = page : page = 0;
//		
//		redraw();
//        g.refresh();
//    }
//    this.send = new Toggles([], [[12,13],n], [[0,0], LO], function() { return page == 0; });
//    this.send.event = function(v, added) {
//        if(v[0] == 0 && v.length == 1 || v[1] == 0 ) {
//            me.location = 1;
//            
//            this.v = [0];
//        } else if(v[0] == 1 || v[1] == 1 ) {
//            me.location = 2;
//            
//            this.v = [1];
//        } else {
//            me.location = 0;
//        }
//        
//         set_bang(me.n, "position", 0);
//    }
    
    var current_output;
    
	//softcut[i].path[0] + " " + softcut[i].path[1] + " " + softcut[i].path[2];
	//"this_device canonical_parent"

    this.route = new Toggle(0, [2,n], [0, HI], function() { return page == 0; });
    this.route.event = function(v) {
		if(me.path) {
        if(v == 1) {
	
			api.path = "this_device canonical_parent";
			var thistrack = api.get("name");
	
			api.path = me.path[0] + " " + me.path[1] + " " + me.path[2];
	
            current_output = api.get("output_routing_type");
            
            post(api.path);
            //post(me.track.get("available_output_routing_types"));
            
            var available = JSON.parse(api.get("available_output_routing_types")).available_output_routing_types;
            for(var i in available) {
                if(available[i].display_name == thistrack) {
                    api.set("output_routing_type" , JSON.stringify({ output_routing_type: available[i] }));
                }
            }
        } else {
			api.path = me.path[0] + " " + me.path[1] + " " + me.path[2];
            api.set("output_routing_type" , current_output);
        }
		} else post("no path for line " + n);
    }
    
    this.pat = new Pattern(0, [7, n], [0, LO, HI], function() { return page == n + 1; }, update);
    
    this.get = function() {
        var ret = {
            menu: this.menu.get(),
            send: this.send.get(),
            pat: this.pat.get(),
            presets: []
        }
        
        for(var i=0; i < this.presets.length; i++) {
            if(this.presets[i]) ret.presets[i] = this.presets[i].get();
            else ret.presets[i] = null;
        }
        
        return ret;
    }
    
    this.set = function(input) {
        for(var i=0; i < input.presets.length; i++) {
            this.presets[i].set(input.presets[i]);
        }
        
        this.menu.set(input.menu);
        this.send.set(input.send);
        this.pat.set(input.pat);
    }
}

var get = function() {
    var thing = [];
    
    for(var i = 0; i < controls.lines.length; i++) {
        thing[i] = controls.lines[i].get();
    }
    
    return JSON.stringify(thing);
}

var diction_out = function() {
    var diction = {};
    diction.softcut = [];
    
    for(var i = 0; i < controls.lines.length; i++) {
        diction.softcut[i] = {}
        
        diction.softcut[i].active = controls.lines[i].preset.i;
        diction.softcut[i].location = controls.lines[i].location;
        diction.softcut[i].presets = [];
        if(controls.lines[i].path) diction.softcut[i].path = controls.lines[i].path;
        
        for(var j = 0; j < controls.lines[i].presets.length; j++) {
            diction.softcut[i].presets[j] = controls.lines[i].presets[j].softcut_get();
        }
    }
    
    output("diction_out", JSON.stringify(diction));
    
    if(diction_bang) {
        output("diction_bang", JSON.stringify(diction_bang));
        
        diction_bang = null;
    }
}

var diction_bang;
var api = new LiveAPI();

var diction_in = function(stringified) {
    var softcut = JSON.parse(stringified).softcut;
    
    for(var i = 0; i < controls.lines.length; i++) {
        
        controls.lines[i].preset_set(softcut[i].active);
		controls.lines[i].location = softcut[i].location;
        if(softcut[i].path != null) controls.lines[i].path = softcut[i].path;
        
        for(var j = 0; j < controls.lines[i].presets.length; j++) {
            controls.lines[i].presets[j].softcut_set(softcut[i].presets[j]);
        }
        
         //controls.lines[i].preset.softcut_set(softcut[i].presets[softcut[i].active]);
    }
    
    redraw();
    g.refresh();
}

var init = function() {
    controls.lines = [];
    
	for(var i = 0; i < 4; i++) {
 		controls.lines[i] = new Line(i);
		
		for(j in controls.lines[i]) {
			if(controls.lines[i][j].draw) {
				controls.lines[i][j].draw(g);
			}
		}
	}
    
    buffdate();
    
	redraw();
	g.refresh();
	
	output("init");
}
