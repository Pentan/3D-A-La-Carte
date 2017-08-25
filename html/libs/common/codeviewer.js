var CodeViewer = {
    /* statuc functions */
    /* code utilities */
    escapeCodeString: function(srctxt) {
        srctxt = srctxt.replace(/</g, '&lt;');
        srctxt = srctxt.replace(/>/g, '&gt;');
        return srctxt;
    },
    makeSimpleCodeHTML: function(srctxt) {
        return '<div class="simplecodewrap"><pre class="simplecodeblock">' + CodeViewer.escapeCodeString(srctxt) + '</pre></div>';
    },
    makeSimpleCodeElement: function(srctxt) {
        var ret = document.createElement('div');
        ret.className = 'simplecodewrap';
        var pre = document.createElement('pre');
        pre.className = 'simplecodeblock';
        pre.innerText = CodeViewer.escapeCodeString(srctxt);
        ret.appendChild(pre);
        return ret;
    },

    /* descripyion */
    makeSimpleDescriptionHTML: function(titletxt, desctxt) {
        if(titletxt === undefined) { titletxt = ""; }
        if(desctxt === undefined) { desctxt = ""; }
        if(titletxt.length === 0 && desctxt.length === 0) {
            return null;
        }
        return '<div class="simpledescwrap"><h1 class="simpledesctitle">' + titletxt + '</h1>' + '<div class="simpledesctext">' + desctxt + '</div></div>';
    },

    /* main */
    /* inject viewer */
    inject: function(rootelm, opts) {
        /*
        default option values.
        opt = {
            canvasSize: {width:512, height:288},
            numCodeTabs: 1,
            numCodeViews: 1,
            noTabBar: false
        }
        */

        if(!rootelm) { rootelm = document.body; }

        // option values
        var canvasSize = {width:512, height:288};
        var codeConfs = {
            numTabs: 1,
            numViews: 1,
            hideTabBar: false
        };
        if(opts) {
            if(opts.canvasSize) {
                canvasSize.width = opts.canvasSize.width;
                canvasSize.height = opts.canvasSize.height;
            }
            if(opts.numCodeTabs !== undefined) {
                codeConfs.numTabs = opts.numCodeTabs;
            }
            if(opts.numCodeViews !== undefined) {
                codeConfs.numViews = opts.numCodeViews;
            }
            if(opts.noTabBar !== undefined) {
                codeConfs.noTabBar = opts.noTabBar;
            }
        }

        var createItem = function (prntelm, tag, cls, id) {
            var newelm = document.createElement(tag);
            if(cls !== undefined) {
                newelm.className = cls;
            }
            if(id !== undefined) {
                newelm.id = id;
            }
            prntelm.appendChild(newelm);
            return newelm;
        }

        var retcntx = new CodeViewer.Context();

        // player column at left
        (function() {
            // main
            var colroot = createItem(rootelm, 'div', 'colleft');
            colroot.style['flex-basis'] = canvasSize.width + 'px';

            // player wrap
            var plywrap = createItem(colroot, 'div', 'playerwrap');

            // canvas
            (function () {
                // inject canvas size css
                var elm = document.createElement('style');
                document.getElementsByTagName('head')[0].appendChild(elm);
                var lastindex = document.styleSheets.length - 1;
                var ssheet = document.styleSheets[lastindex];
                ssheet.insertRule('.canvassize{ width:' + canvasSize.width + 'px; height:' + canvasSize.height + 'px; }', 0);
            })();
            var cnvs = createItem(plywrap, 'canvas', 'playercanvas canvassize');
            cnvs.id = "playerCanvas";
            cnvs.width = canvasSize.width;
            cnvs.height = canvasSize.height;
            retcntx.setCanvas(cnvs);
            /*
            CodeViewer._fullscreen.addEventListener(cnvs, function(e) {
                console.log('fullscreen change:' + CodeViewer._fullscreen.isFull());
            });
            */

            // controller
            var tmpbtn;
            var ctrlroot = createItem(plywrap, 'div', 'playerctrl');

            // left side buttons
            var ctrl_l = createItem(ctrlroot, 'div', 'playerctrl_l');
            tmpbtn = createItem(ctrl_l, 'button', 'playerbtn', 'playBtn');
            tmpbtn.type = 'button';
            tmpbtn.innerText = 'Play';
            tmpbtn.addEventListener('click', retcntx._playHandler, false);
            retcntx.addButton('playButton', tmpbtn);

            tmpbtn = createItem(ctrl_l, 'button', 'playerbtn', 'resetBtn');
            tmpbtn.type = 'button';
            tmpbtn.innerText = 'Reset';
            tmpbtn.addEventListener('click', retcntx._resetHandler, false);
            retcntx.addButton('resetButton', tmpbtn);

            // right side buttons
            var ctrl_r = createItem(ctrlroot, 'div', 'playerctrl_r');
            tmpbtn = createItem(ctrl_r, 'button', 'playerbtn', 'fullScreenBtn');
            tmpbtn.type = 'button';
            tmpbtn.innerText = 'Fullscreen';
            tmpbtn.addEventListener('click', retcntx._fullscreenHandler, false);
            retcntx.addButton('fullscreenButton', tmpbtn);
            
            // descriptions
            retcntx.descriptionView = createItem(colroot, 'div', 'codedesc');

        })();
        
        // code column at right
        (function () {
            // main
            var colroot = createItem(rootelm, 'div', 'colright')

            // header
            if(!codeConfs.noTabBar) {
                var header = createItem(colroot, 'div', 'codeheader');
                for(var i = 0; i < codeConfs.numTabs; i++) {
                    var clsname = 'codetab';
                    if(i == 0) {
                        clsname += ' codetabsel';
                    }
                    var tmptab = createItem(header, 'div', clsname, 'codetab_' + i);
                    retcntx.addTab(tmptab);
                    tmptab.innerText = "Tab " + i;
                }
            }

            // code
            var viewwrap = createItem(colroot, 'div', 'codewrap');
            for(var i = 0; i < codeConfs.numViews; i++) {
                var tmpview = createItem(viewwrap, 'div', 'codeview', 'codeview_' + i);
                retcntx.addCodeView(tmpview);
                //tmpview.innerText = "Code " + i;
            }
        })();

        return retcntx;
    },

    /* WebGL Utilities */
    WebGL1: {
        compileShader: function(gl, type, src) {
            var sh = gl.createShader(type);
            gl.shaderSource(sh, src);
            gl.compileShader(sh);
            var err = gl.getShaderParameter(sh, gl.COMPILE_STATUS);
            if(!err) {
                var errlog = gl.getShaderInfoLog(sh);
                gl.deleteShader(sh);
                throw 'Shader compile error Exception: ' + errlog;
            }
            return sh;
        },

        linkShaders: function(gl, vsh, fsh) {
            var prg = gl.createProgram();
            gl.attachShader(prg, vsh);
            gl.attachShader(prg, fsh);
            gl.linkProgram(prg);
            var err = gl.getProgramParameter(prg, gl.LINK_STATUS);
            if(!err) {
                var errlog = gl.getProgramInfoLog(prg);
                gl.deleteProgram(prg);
                throw 'Program link error Exception: ' + errlog;
            }
            return prg;
        },

        createShaderProgram: function(gl, vtxsrc, frgsrc) {
            var vsh = CodeViewer.WebGL1.compileShader(gl, gl.VERTEX_SHADER, vtxsrc);
            var fsh = CodeViewer.WebGL1.compileShader(gl, gl.FRAGMENT_SHADER, frgsrc);
            var prog = CodeViewer.WebGL1.linkShaders(gl, vsh, fsh);
            gl.deleteShader(vsh);
            gl.deleteShader(fsh);
            return prog;
        },

        createTexture: function(gl, w, h, texopts, datopts) {
            // default texture settings
            var texspec = {
                target: gl.TEXTURE_2D,
                format: gl.RGBA,
                wrap_s: gl.CLAMP_TO_EDGE,
                wrap_t: gl.CLAMP_TO_EDGE,
                min_filter: gl.LINEAR,
                mag_filter: gl.LINEAR
            };
            if(texopts !== undefined) {
                for(var k in texopts) {
                    texspec[k] = texopts[k];
                }
            }

            // default data settings
            var datspec = {
                data: null,
                format: gl.RGBA,
                type: gl.UNSIGNED_BYTE
            };
            if(datopts !== undefined) {
                for(var k in datopts) {
                    datspec[k] = datopts[k];
                }
            }

            var tex = gl.createTexture();
            gl.bindTexture(texspec.target, tex);
            gl.texImage2D(texspec.target, 0, texspec.format, w, h, 0, datspec.format, datspec.type, datspec.data);
            gl.texParameteri(texspec.target, gl.TEXTURE_WRAP_S, texspec.wrap_s);
            gl.texParameteri(texspec.target, gl.TEXTURE_WRAP_T, texspec.wrap_t);
            gl.texParameteri(texspec.target, gl.TEXTURE_MAG_FILTER, texspec.mag_filter);
            gl.texParameteri(texspec.target, gl.TEXTURE_MIN_FILTER, texspec.min_filter);
            gl.bindTexture(texspec.target, null);
            return tex;
        },

        createFramebuffer: function(gl, w, h, texopts) {
            // default texture option values
            var texspec = {
                wrap_s: gl.CLAMP_TO_EDGE,
                wrap_t: gl.CLAMP_TO_EDGE,
                mag_filter: gl.NEAREST,
                min_filter: gl.NEAREST
            };
            if(texopts !== undefined) {
                for(var k in texops) {
                    texspec[k] = texopts[k];
                }
            }

            var fb = gl.createFramebuffer();
            var rb = gl.createRenderbuffer();
            var tex = gl.createTexture();

            gl.bindTexture(gl.TEXTURE_2D, tex);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, texspec.wrap_s);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, texspec.wrap_t);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, texspec.mag_filter);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, texspec.min_filter);
            
            gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
            gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0);
            //console.log("FB tex attached:" + gl.getError());

            gl.bindRenderbuffer(gl.RENDERBUFFER, rb);
            gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, w, h);
            gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, rb);
            //console.log("FB rb attached:" + gl.getError());
            
            gl.bindTexture(gl.TEXTURE_2D, null);
            gl.bindRenderbuffer(gl.RENDERBUFFER, null);
            gl.bindFramebuffer(gl.FRAMEBUFFER, null);

            return {width:w, height:h, framebuffer:fb, texture:tex};
        }
    },

    /* Fullscreen utilities */
    _fullscreen: {
        request: function(e) {
            if(e.requestFullscreen ) {
                e.requestFullscreen();
            } else if(e.msRequestFullscreen) {
                e.msRequestFullscreen();
            } else if(e.mozRequestFullScreen) {
                e.mozRequestFullScreen();
            } else if(e.webkitRequestFullscreen) {
                e.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
            }
        },
        
        isFull: function() {
            return document.fullscreen || document.mozFullScreen || document.webkitIsFullScreen || document.msFullscreenElement || false;
        },
        
        exit: function() {
            if(document.exitFullscreen) {
                document.exitFullscreen();
            } else if(document.msExitFullscreen) {
                document.msExitFullscreen();
            } else if(document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if(document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            }
        },

        addEventListener: function(func) {
            document.addEventListener('webkitfullscreenchange', func, false);
            document.addEventListener('mozfullscreenchange', func, false);
            document.addEventListener('fullscreenchange', func, false);
            document.addEventListener('MSFullscreenChange', func, false);
        }
    },

    /* viewer context object */
    Context: function() {
        this.canvas = null;
        this.descriptionView = null;
        this.buttons = {};
        this.tabs = [];
        this.tabIdIndexTbl = {}
        this.codeViews = [];
        this.tabChangedListener = null;
        this.isPlaying = false;

        this._currentSize = {width: 0, height: 0};
        this._selectedTabIndex = 0;
        this._eventListener = {};
        this._fullscreenFuncName = null;

        // event handlers
        var thisref = this;

        this._tabChangeHandler = function(event) {
            //console.log(event);
            //console.log("index:" + thisref.tabIdIndexTbl[event.target.id]);
            var index = thisref.tabIdIndexTbl[event.target.id];
            if(index != thisref._selectedTabIndex) {
                thisref.tabs[thisref._selectedTabIndex].className = 'codetab';
                thisref.tabs[index].className = 'codetab codetabsel';
                var preindex = thisref._selectedTabIndex;
                thisref._selectedTabIndex = index;

                if(thisref._eventListener.tabChanged) {
                    thisref._eventListener.tabChanged(thisref, index, preindex);
                }
            }
        };

        this._playHandler = function() {
            var btn = thisref.buttons['playButton'];
            if(thisref.isPlaying) {
                // to pause
                btn.innerText = "Play";
                thisref.isPlaying = false;
                if(thisref._eventListener.pause) {
                    thisref._eventListener.pause(thisref);
                }
            } else {
                // to play
                btn.innerText = "Pause";
                thisref.isPlaying = true;
                if(thisref._eventListener.play) {
                    thisref._eventListener.play(thisref);
                }
            }
        };

        this._resetHandler = function() {
            if(thisref._eventListener.reset) {
                thisref._eventListener.reset(thisref);
            }
        };

        this._fullscreenHandler = function() {
            CodeViewer._fullscreen.request(thisref.canvas);
            if(thisref._eventListener.fullscreen) {
                thisref._eventListener.fullscreen(thisref, thisref.canvas);
            }
        };

        var resizeFunc = function() {
            //console.log('window resized');
            if( thisref.canvas.clientWidth != thisref._currentSize.width ||
                thisref.canvas.clientHeight != thisref._currentSize.height)
            {
                thisref._currentSize.width = thisref.canvas.clientWidth;
                thisref._currentSize.height = thisref.canvas.clientHeight;
                if(thisref._eventListener.resize) {
                    thisref._eventListener.resize(thisref, thisref.canvas);
                }
            }
        };
        window.addEventListener('resize', resizeFunc, false);
        CodeViewer._fullscreen.addEventListener(resizeFunc);
    },
};

CodeViewer.Context.prototype.addButton = function (id, elm) {
    this.buttons[id] = elm;
}

CodeViewer.Context.prototype.addTab = function (elm) {
    this.tabs.push(elm);
    this.tabIdIndexTbl[elm.id] = this.tabs.length - 1;
    elm.addEventListener('click', this._tabChangeHandler, false);
}

CodeViewer.Context.prototype.setTabTitleText = function (i, txt) {
    this.tabs[i].innerText = txt;
}

CodeViewer.Context.prototype.addCodeView = function (elm) {
    this.codeViews.push(elm);
}

CodeViewer.Context.prototype.setCanvas = function (elm, w, h) {
    this.canvas = elm;
    this._currentSize.width = (w === undefined)? elm.width : w;
    this._currentSize.height = (h === undefined)? elm.height : h;
}

/*
eventListener = {
    tabChanged: function(context, selectedIndex, unselectedIndex), // tab selected
    play: function(context), // play button pushed
    pause: function(context), // pause button pushed
    reset: function(context), // reset button pushed
    fullscreen: function(context, canvas), // fullscreen button pushed
    resize: function(context, canvas), // canvas resized
}
*/
CodeViewer.Context.prototype.setEventListener = function (l) {
    this._eventListener = l;
}

CodeViewer.Context.prototype.play = function () {
    if(!this.isPlaying) {
        this._playHandler();
    }
}
