
window.addEventListener('load',function () {
    // setup viewer
    var cvcntx = CodeViewer.inject(document.body);
    // code desc
    if(kCodeDescription) {
        var deschtml = CodeViewer.makeSimpleDescriptionHTML(kCodeDescription.title, kCodeDescription.text);
        if(deschtml) {
            cvcntx.descriptionView.innerHTML = deschtml;
        }
    }
    // tab title
    cvcntx.setTabTitleText(0, document.title? document.title:"Fragment Shader");
    // inject source view
    var shadersrc = document.getElementById('shadersrc').textContent;
    cvcntx.codeViews[0].innerHTML = CodeViewer.makeSimpleCodeHTML(shadersrc);

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
        var vtxsrc = "attribute vec3 aPos;void main(void){gl_Position=vec4(aPos,1.0);}";
        var prog = CodeViewer.WebGL1.createShaderProgram(gl, vtxsrc, shadersrc);

        var uniforms = {
            time: gl.getUniformLocation(prog, "time"),
            resolution:  gl.getUniformLocation(prog, "resolution"),
            mouse: gl.getUniformLocation(prog, "mouse"),
            backbuffer: gl.getUniformLocation(prog, "backbuffer"),
            surfaceSize: gl.getUniformLocation(prog, "surfaceSize"),
        };
        var attribs = {
            'aPos': gl.getAttribLocation(prog, "aPos")
        };
        return {program: prog, uniforms: uniforms, attribs: attribs};
    })();

    var flipshader = (function() {
        var vtxsrc = "attribute vec3 aPos; void main(void){gl_Position=vec4(aPos,1.0);}";
        var frgsrc = "#ifdef GL_ES\n precision mediump float;\n #endif\n uniform sampler2D backbuffer; uniform vec2 resolution; void main(void){vec2 uv=gl_FragCoord.xy/resolution.xy; gl_FragColor=texture2D(backbuffer,uv);}";
        var prog = CodeViewer.WebGL1.createShaderProgram(gl, vtxsrc, frgsrc);

        var uniforms = {
            resolution:  gl.getUniformLocation(prog, "resolution"),
            backbuffer: gl.getUniformLocation(prog, "backbuffer")
        };
        var attribs = {
            'aPos': gl.getAttribLocation(prog, "aPos")
        };
        return {program: prog, uniforms: uniforms, attribs: attribs};
    })();

    // framebuffers
    var framebuffers = {front: null, back:null};
    var createFramebuffers = function() {
        framebuffers.front = CodeViewer.WebGL1.createFramebuffer(gl, cvcntx.canvas.width, cvcntx.canvas.height);
        framebuffers.back = CodeViewer.WebGL1.createFramebuffer(gl, cvcntx.canvas.width, cvcntx.canvas.height);
        //return framebuffers;
    };
    createFramebuffers();

    // vertex buffer
    var buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER,
        new Float32Array([
             1.0,  1.0,
            -1.0,  1.0,
             1.0, -1.0,
            -1.0, -1.0,
        ]),
        gl.STATIC_DRAW);
    
    // mouse event
    var mouse = {'x':0.5, 'y':0.5};
    cvcntx.canvas.addEventListener('mousemove', function(e) {
        mouse.x = (e.pageX - e.currentTarget.offsetLeft) / e.currentTarget.width;
        mouse.y = 1.0 - (e.pageY - e.currentTarget.offsetTop) / e.currentTarget.height;
    }, false);
    
    // update function
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
        gl.bindBuffer(gl.ARRAY_BUFFER, buf);
        gl.enableVertexAttribArray(shaderfx.attribs.aPos);
        gl.vertexAttribPointer(shaderfx.attribs.aPos, 2, gl.FLOAT, false, 0, 0);
        
        if(shaderfx.uniforms.time) {
            gl.uniform1f(shaderfx.uniforms.time, shaderTime.elapsed / 1000.0);
        }
        if(shaderfx.uniforms.resolution) {
            gl.uniform2f(shaderfx.uniforms.resolution, cvcntx.canvas.width, cvcntx.canvas.height);
        }
        if(shaderfx.uniforms.mouse) {
            gl.uniform2f(shaderfx.uniforms.mouse, mouse.x, mouse.y);
        }
        if(shaderfx.uniforms.backbuffer) {
            gl.uniform1i(flipshader.uniforms.backbuffer, 0);
            gl.activeTexture(gl.TEXTURE0);
            gl.bindTexture(gl.TEXTURE_2D, framebuffers.back.texture);
        }
        if(shaderfx.uniforms.surfaceSize) {
            // zoom, pan is not supported
            gl.uniform2f(shaderfx.uniforms.surfaceSize, (cvcntx.canvas.width / cvcntx.canvas.height), 1.0);
        }
        
        gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffers.back.framebuffer);
        gl.viewport(0, 0, cvcntx.canvas.width, cvcntx.canvas.height);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.disable(gl.DEPTH_TEST);
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
        
        gl.disableVertexAttribArray(shaderfx.attribs.aPos);

        // flip to front
        gl.useProgram(flipshader.program);
        gl.bindBuffer(gl.ARRAY_BUFFER, buf);
        gl.enableVertexAttribArray(flipshader.attribs.aPos);
        gl.vertexAttribPointer(flipshader.attribs.aPos, 2, gl.FLOAT, false, 0, 0);
        
        gl.uniform2f(flipshader.uniforms.resolution, cvcntx.canvas.width, cvcntx.canvas.height);
        gl.uniform1i(flipshader.uniforms.backbuffer, 0);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, framebuffers.back.texture);

        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
        gl.viewport(0, 0, cvcntx.canvas.width, cvcntx.canvas.height);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.disable(gl.DEPTH_TEST);
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

        gl.disableVertexAttribArray(flipshader.attribs.aPos);

        // swap buffer
        (function(f, b) {
            framebuffers.front = b;
            framebuffers.back = f;
        })(framebuffers.front, framebuffers.back);

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
            createFramebuffers();
            if(!cvcntx.isPlaying) {
                update();
            }
        }
    });

    cvcntx.play();
});
