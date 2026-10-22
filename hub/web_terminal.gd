class_name MatrixWebTerminal
extends Node
## Real DOM text input: browser/OS keyboard activation stays inside a user tap.
## No destinations are copied into JavaScript, HTML or the accessibility tree.

var hub: MatrixHub
const SOURCE: String = """
(() => {
 if (window.matrixTerminal) return;
 const host = document.createElement('div');
 host.id = 'matrix-terminal';
 host.style.cssText = 'position:fixed;inset:0;z-index:100;display:none;background:rgba(2,8,8,.94);align-items:center;justify-content:center;color:#80b99d;font:16px monospace';
 const form = document.createElement('form');
 form.setAttribute('aria-label','Matrix terminal');
 form.style.cssText = 'box-sizing:border-box;width:min(800px,calc(100vw - 32px));height:min(350px,calc(100dvh - 24px));border:1px solid #305846;padding:20px 24px;background:#030b09;position:relative';
 const header = document.createElement('div');
 header.style.cssText='font:13px monospace;letter-spacing:3px;color:#4d7966;margin-bottom:32px';
 header.textContent='MATRIX';
 const close = document.createElement('button');
 close.type='button'; close.textContent='ESC'; close.setAttribute('aria-label','Close terminal');
 close.style.cssText='position:absolute;right:12px;top:8px;min-width:52px;min-height:44px;border:0;background:transparent;color:#789e8b;font:14px monospace';
 const row = document.createElement('label');
 row.style.cssText='display:flex;align-items:center;gap:14px;border-bottom:1px solid #234b3a';
 const prompt=document.createElement('span');prompt.textContent='>';
 const input=document.createElement('input');
 input.type='text';input.maxLength=18;input.autocomplete='off';input.spellcheck=false;
 input.setAttribute('autocorrect','off');input.setAttribute('autocapitalize','characters');
 input.setAttribute('enterkeyhint','go');input.setAttribute('inputmode','text');
 input.setAttribute('aria-label','Terminal input');input.name='terminal-input';
 input.style.cssText='box-sizing:border-box;width:100%;min-width:0;height:48px;background:transparent;border:0;outline:0;border-radius:0;color:#8cccaa;caret-color:#a3ddba;font:24px monospace;letter-spacing:2px';
 const status=document.createElement('div');status.setAttribute('aria-live','polite');
 status.style.cssText='font:14px monospace;color:#b39472;margin-top:18px';
 const enter=document.createElement('button');enter.type='submit';enter.textContent='ENTER';
 enter.style.cssText='margin-top:16px;min-width:76px;min-height:44px;background:transparent;border:1px solid #254935;color:#729d84;font:14px monospace';
 row.append(prompt,input);form.append(header,close,row,enter,status);host.append(form);document.body.append(host);
 let commands=[];
 const layout=()=>{
  const viewport=window.visualViewport;
  const height=viewport?.height||innerHeight;
  host.style.height=height+'px';host.style.top=(viewport?.offsetTop||0)+'px';host.style.bottom='auto';
  form.style.height=Math.min(350,Math.max(140,height-24))+'px';
  const compact=height<300;
  form.style.padding=compact?'10px 20px':'20px 24px';
  form.style.overflow='auto';
  status.style.position=compact?'absolute':'static';
  status.style.left=compact?'124px':'';status.style.top=compact?'100px':'';
  status.style.right=compact?'20px':'';
  header.style.marginBottom=compact?'8px':'32px';
  enter.style.marginTop=compact?'8px':'16px';status.style.marginTop=compact?'8px':'18px';
 };
 window.addEventListener('resize',layout);window.visualViewport?.addEventListener('resize',layout);window.visualViewport?.addEventListener('scroll',layout);
 const dismiss=()=>commands.push('close');
 close.addEventListener('click',dismiss);
 form.addEventListener('submit',e=>{e.preventDefault();commands.push('submit')});
 input.addEventListener('input',()=>{const pos=input.selectionStart;input.value=input.value.toUpperCase().slice(0,18);input.setSelectionRange(pos,pos)});
 host.addEventListener('keydown',e=>{e.stopPropagation();if(e.key==='Escape'){e.preventDefault();dismiss()}});
 host.addEventListener('keyup',e=>e.stopPropagation());
 // A genuine tap on this input is what invokes the phone OS keyboard. No fake keypad.
 window.matrixTerminal={
  show(){commands=[];input.value='';status.textContent='';host.style.display='flex';layout();input.focus({preventScroll:true})},
  hide(){input.blur();host.style.display='none';commands=[];document.querySelector('canvas')?.focus({preventScroll:true})},
  read(){return JSON.stringify({value:input.value,command:commands.shift()||''})},
  update(value,message){input.value=value;status.textContent=message},
  destroy(){window.removeEventListener('resize',layout);window.visualViewport?.removeEventListener('resize',layout);window.visualViewport?.removeEventListener('scroll',layout);host.remove();delete window.matrixTerminal}
 };
})();
"""

func _ready() -> void:
	set_process(false)


func open() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval(SOURCE, true)
	JavaScriptBridge.eval("window.matrixTerminal.show()", true)
	set_process(true)


func close() -> void:
	if not OS.has_feature("web") or not is_processing():
		return
	JavaScriptBridge.eval("window.matrixTerminal?.hide()", true)
	set_process(false)


func _process(_delta: float) -> void:
	if not hub.overlay.terminal_active:
		close()
		return
	var state: Dictionary = JSON.parse_string(str(JavaScriptBridge.eval("window.matrixTerminal.read()", true)))
	hub.overlay.input_text = str(state.value)
	if state.command == "close":
		hub.close_terminal()
	elif state.command == "submit":
		hub.submit_code()
		JavaScriptBridge.eval("window.matrixTerminal.update(%s,%s)" % [JSON.stringify(hub.overlay.input_text), JSON.stringify(hub.overlay.message)], true)


func _exit_tree() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.matrixTerminal?.destroy()", true)
