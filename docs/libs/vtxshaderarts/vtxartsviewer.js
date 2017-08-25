window.addEventListener('load',function () {
    // default values
    var kVertexCount = 10000;
    var kBackground = new Float32Array([0.0, 0.0, 0.0, 0.0]);
    var kDrawMode = 'POINTS';

    if(kEffectDefinition) {
        if(kEffectDefinition.vertexCount !== undefined) {
            kVertexCount = kEffectDefinition.vertexCount;
        }

        if(kEffectDefinition.background !== undefined) {
            var colcomps = ['r', 'g', 'b', 'a'];
            for(var i = 0; i < 4; i++) {
                if(kEffectDefinition.background[colcomps[i]] !== undefined) {
                    kBackground[i] = kEffectDefinition.background[colcomps[i]];
                }
            }
        }

        if(kEffectDefinition.drawMode !== undefined) {
            kDrawMode = kEffectDefinition.drawMode;
        }
    }

    // setup viewer
    var cvcntx = CodeViewer.inject(document.body);
    // code desc
    if(kEffectDefinition && kEffectDefinition.description) {
        var titletxt = kEffectDefinition.description.title;
        var desctxt = kEffectDefinition.description.text;
        var deschtml = CodeViewer.makeSimpleDescriptionHTML(titletxt, desctxt);
        if(deschtml) {
            cvcntx.descriptionView.innerHTML = deschtml;
        }
    }
    // tab title
    cvcntx.setTabTitleText(0, document.title? document.title:"Vertex Shader");
    // inject source view
    var shadersrc = document.getElementById('shadersrc').textContent;
    cvcntx.codeViews[0].innerHTML = CodeViewer.makeSimpleCodeHTML(shadersrc);

    // inject vertex shader info
    (function() {
        var leftctrl = document.getElementsByClassName('playerctrl_l')[0];
        var tmpnode = document.createElement('span');
        tmpnode.className = 'vtxshaderinfo';
        tmpnode.innerHTML = kVertexCount + " verts. " + kDrawMode;
        leftctrl.appendChild(tmpnode);
    })();

    // setup WebGL
    var cntx = null;
    try {
        var attr = {
            preserveDrawingBuffer: true,
            alpha: false,
            antialias: false
        }
        cntx = cvcntx.canvas.getContext('webgl', attr);
    } catch(e) {
        window.alert('This browser is not supprt WebGL.');
    }
    var gl = cntx;
    gl.getExtension('OES_standard_derivatives');

    // shader setup
    var shaderfx = (function() {
        var vtxsrc = [
            "attribute float vertexId;",
            "uniform float vertexCount;",
            "uniform vec2 resolution;",
            "uniform vec2 mouse;",
            "uniform sampler2D touch;",
            "uniform float time;",
            "uniform sampler2D sound;",
            "uniform sampler2D floatSound;",
            "uniform vec2 soundRes;",
            "uniform vec4 background;",
            "varying vec4 v_color;",
            shadersrc
        ].join('\n');
        var frgsrc = "#ifdef GL_ES\n precision mediump float;\n #endif\n varying vec4 v_color; void main(void){gl_FragColor=v_color;}";
        var prog = CodeViewer.WebGL1.createShaderProgram(gl, vtxsrc, frgsrc);

        var uniforms = {
            vertexCount: gl.getUniformLocation(prog, "vertexCount"),
            resolution:  gl.getUniformLocation(prog, "resolution"),
            mouse: gl.getUniformLocation(prog, "mouse"),
            touch: gl.getUniformLocation(prog, "touch"),
            time: gl.getUniformLocation(prog, "time"),
            sound: gl.getUniformLocation(prog, "sound"),
            floatSound: gl.getUniformLocation(prog, "floatSound"),
            soundRes: gl.getUniformLocation(prog, "soundRes"),
            background: gl.getUniformLocation(prog, "background"),
        };
        var attribs = {
            'vertexId': gl.getAttribLocation(prog, "vertexId")
        };
        return {program: prog, uniforms: uniforms, attribs: attribs};
    })();

    // vertex buffer
    var vtxbuf = (function() {
        var tmparray = new Float32Array(kVertexCount);
        for(var i = 0; i < kVertexCount; i++) {
            tmparray[i] = i;
        }

        var tmpbuf = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, tmpbuf);
        gl.bufferData(gl.ARRAY_BUFFER, tmparray, gl.STATIC_DRAW);
        return tmpbuf;
    })();
    
    // mouse event
    var mouse = {'x':0.0, 'y':0.0};
    cvcntx.canvas.addEventListener('mousemove', function(e) {
        mouse.x = (e.pageX - e.currentTarget.offsetLeft) / e.currentTarget.width * 2.0 - 1.0;
        mouse.y = (e.pageY - e.currentTarget.offsetTop) / e.currentTarget.height * -2.0 + 1.0;
    }, false);
    
    // textures (dummy)
    var touchtex = CodeViewer.WebGL1.createTexture(gl, 32, 240);
    var fftBins = 32;
    var soundtex = CodeViewer.WebGL1.createTexture(gl, fftBins, 240);
    var fsoundtex = CodeViewer.WebGL1.createTexture(gl, fftBins, 240);

    // update function
    var glDrawMode = gl[kDrawMode];
    if(glDrawMode === undefined) {
        throw 'unknown draw mode:' + kDrawMode;
    }
    var shaderTime = {prev: null, elapsed:0.0};
    var update = function(ts) {
        if(ts === undefined) {
            shaderTime.prev = null;
        } else {
            if(shaderTime.prev !== null) {
                shaderTime.elapsed += ts - shaderTime.prev;
            }
            shaderTime.prev = ts;
        }

        // draw effect in backbuffer
        gl.useProgram(shaderfx.program);
        gl.bindBuffer(gl.ARRAY_BUFFER, vtxbuf);
        gl.enableVertexAttribArray(shaderfx.attribs.vertexId);
        gl.vertexAttribPointer(shaderfx.attribs.vertexId, 1, gl.FLOAT, false, 0, 0);

        // uniforms
        if(shaderfx.uniforms.vertexCount) {
            gl.uniform1f(shaderfx.uniforms.vertexCount, kVertexCount);
        }
        if(shaderfx.uniforms.resolution) {
            gl.uniform2f(shaderfx.uniforms.resolution, cvcntx.canvas.width, cvcntx.canvas.height);
        }
        if(shaderfx.uniforms.mouse) {
            gl.uniform2f(shaderfx.uniforms.mouse, mouse.x, mouse.y);
        }
        if(shaderfx.uniforms.touch) {
            gl.uniform1i(flipshader.uniforms.touch, 0);
            gl.activeTexture(gl.TEXTURE0);
            gl.bindTexture(gl.TEXTURE_2D, touchtex);
        }
        if(shaderfx.uniforms.time) {
            gl.uniform1f(shaderfx.uniforms.time, shaderTime.elapsed / 1000.0);
        }
        if(shaderfx.uniforms.sound) {
            gl.uniform1i(flipshader.uniforms.sound, 1);
            gl.activeTexture(gl.TEXTURE1);
            gl.bindTexture(gl.TEXTURE_2D, soundtex);
        }
        if(shaderfx.uniforms.floatSound) {
            gl.uniform1i(flipshader.uniforms.floatSound, 2);
            gl.activeTexture(gl.TEXTURE2);
            gl.bindTexture(gl.TEXTURE_2D, fsoundtex);
        }
        if(shaderfx.uniforms.soundRes) {
            gl.uniform2f(shaderfx.uniforms.soundRes, fftBins, 240);
        }
        if(shaderfx.uniforms.background) {
            gl.uniform4fv(shaderfx.uniforms.background, kBackground);
        }
        
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
        gl.viewport(0, 0, cvcntx.canvas.width, cvcntx.canvas.height);
        gl.clearColor(kBackground[0], kBackground[1], kBackground[2], kBackground[3]);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
        gl.disable(gl.CULL_FACE);
        gl.drawArrays(glDrawMode, 0, kVertexCount);
        
        gl.disableVertexAttribArray(shaderfx.attribs.vertexId);

        if(cvcntx.isPlaying) {
            requestAnimationFrame(update);
        }
    };

    // event listener
    cvcntx.setEventListener({
        play: function(cv) {
            shaderTime.prev = null;
            update();
        },
        reset: function(cv) {
            shaderTime.elapsed = 0.0;
            if(!cvcntx.isPlaying) {
                update();
            }
        },
        resize: function(cv, cnvs) {
            //console.log('canvas resized:' + cnvs.clientWidth + ',' + cnvs.clientHeight + ')');
            cvcntx.canvas.width = cnvs.clientWidth;
            cvcntx.canvas.height = cnvs.clientHeight;
            if(!cvcntx.isPlaying) {
                update();
            }
        }
    });

    cvcntx.play();
});
