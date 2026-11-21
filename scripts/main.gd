extends Node3D

const SAVE_PATH := "user://sentinel_memory.json"
var history: Array = []
var tasks: Array = []
var status_label: Label
var chat_log: RichTextLabel
var message_input: LineEdit
var agent: Node3D
var anim_time := 0.0
var current_task := 0
var voice_enabled := true
var research_topics := ["Redes TCP/IP", "DNS y privacidad", "Seguridad Android", "Linux y permisos", "Criptografía básica", "Análisis de registros"]
var camera: Camera3D
var orbit_angle := 0.35
var touch_start := Vector2.ZERO

func _ready() -> void:
	_load_memory()
	_build_world()
	_build_ui()
	_append("SENTINEL", "Sistema V0.1 iniciado. Laboratorio local listo. El motor LLM todavía no está integrado.")
	if tasks.is_empty():
		_add_task("Estudiar " + research_topics[0])
	_update_status()

func _process(delta: float) -> void:
	anim_time += delta
	if agent:
		agent.position.y = 0.035 * sin(anim_time * 1.7)
	if camera:
		camera.position = Vector3(5.7 * sin(orbit_angle), 3.3, 5.7 * cos(orbit_angle))
		camera.look_at(Vector3(0, 1.15, 0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
	elif event is InputEventScreenDrag:
		if event.position.y < get_viewport().get_visible_rect().size.y * 0.66:
			orbit_angle += event.relative.x * 0.005

func _mat(color: Color, emission := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if emission:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.8
	return m

func _cube(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.material_override = _mat(color, glow)
	n.position = pos
	parent.add_child(n)
	return n

func _sphere(parent: Node3D, name: String, pos: Vector3, radius: float, color: Color) -> void:
	var n := MeshInstance3D.new()
	n.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	n.mesh = mesh
	n.material_override = _mat(color)
	n.position = pos
	parent.add_child(n)

func _build_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("10172a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c8dcff")
	env.ambient_light_energy = 0.75
	world.environment = env
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48, 35, 0)
	light.light_energy = 1.4
	add_child(light)
	_cube(self, "Suelo", Vector3(0,-0.16,0), Vector3(8,0.25,8), Color("25324a"))
	_cube(self, "Pared", Vector3(0,2,-3.8), Vector3(8,4,0.2), Color("18243b"))
	_cube(self, "Escritorio", Vector3(0,0.83,-1.65), Vector3(3.4,0.15,1.05), Color("4d5c75"))
	for x in [-1.4,1.4]:
		_cube(self, "Pata", Vector3(x,0.4,-1.65), Vector3(0.13,0.8,0.13), Color("25364d"))
	for x in [-0.85,0.85]:
		_cube(self, "Pantalla", Vector3(x,1.56,-1.8), Vector3(1.35,0.83,0.12), Color("0b1020"))
		_cube(self, "Pantalla iluminada", Vector3(x,1.56,-1.725), Vector3(1.2,0.68,0.02), Color("1679a4"), true)
		_cube(self, "Soporte", Vector3(x,1.05,-1.8), Vector3(0.08,0.35,0.08), Color("62718d"))
	_cube(self, "Teclado", Vector3(0,0.94,-1.22), Vector3(1.0,0.05,0.27), Color("111a2d"))
	for y in range(4):
		_cube(self, "Estante", Vector3(3.2,0.6+y*0.8,-2.7), Vector3(0.85,0.08,1.7), Color("496077"))
	for i in range(7):
		_cube(self, "Libro", Vector3(3.1,1.0+(i%3)*0.8,-3.3+(i/3)*0.3), Vector3(0.12,0.4,0.24), Color("267b9c"))
	agent = Node3D.new()
	agent.name = "SentinelCharacter"
	add_child(agent)
	_cube(agent, "Cuerpo", Vector3(0,1.1,0), Vector3(0.75,1.0,0.42), Color("175b85"))
	_sphere(agent, "Cabeza", Vector3(0,1.93,0), 0.36, Color("d9a58b"))
	_cube(agent, "Pelo", Vector3(0,2.23,-0.04), Vector3(0.69,0.19,0.63), Color("141923"))
	for x in [-0.52,0.52]:
		_cube(agent, "Brazo", Vector3(x,1.12,0), Vector3(0.24,0.9,0.25), Color("175b85"))
	for x in [-0.22,0.22]:
		_cube(agent, "Pierna", Vector3(x,0.38,0), Vector3(0.28,0.75,0.3), Color("182334"))
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 55.0
	add_child(camera)

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(root)
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 8)
	root.add_child(layout)
	var heading := Label.new()
	heading.text = "  SENTINEL AI  |  LABORATORIO"
	heading.add_theme_color_override("font_color", Color("8bdcf6"))
	layout.add_child(heading)
	status_label = Label.new()
	status_label.text = "  Iniciando..."
	layout.add_child(status_label)
	var space := Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(space)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 390)
	layout.add_child(panel)
	var inner := VBoxContainer.new()
	panel.add_child(inner)
	chat_log = RichTextLabel.new()
	chat_log.bbcode_enabled = true
	chat_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(chat_log)
	var row := HBoxContainer.new()
	inner.add_child(row)
	message_input = LineEdit.new()
	message_input.placeholder_text = "Pregunta sobre informática..."
	message_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_input.text_submitted.connect(_send)
	row.add_child(message_input)
	var send := Button.new()
	send.text = "Enviar"
	send.pressed.connect(func(): _send(message_input.text))
	row.add_child(send)
	var actions := HBoxContainer.new()
	inner.add_child(actions)
	for label_text in ["Investigar", "Memoria", "Estado", "Voz"]:
		var b := Button.new()
		b.text = label_text
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_action.bind(label_text))
		actions.add_child(b)

func _append(who: String, msg: String) -> void:
	if chat_log:
		chat_log.append_text("[color=#70d7fa]" + who + ":[/color] " + msg.replace("[", "(").replace("]", ")") + "\n\n")

func _send(text: String) -> void:
	text = text.strip_edges()
	if text.is_empty(): return
	_append("TÚ", text)
	message_input.clear()
	history.append({"role":"user","text":text,"time":Time.get_unix_time_from_system()})
	var reply := _offline_reply(text)
	history.append({"role":"assistant","text":reply,"time":Time.get_unix_time_from_system()})
	_append("SENTINEL", reply)
	_save_memory()

func _offline_reply(question: String) -> String:
	var q := question.to_lower()
	if "dns" in q:
		return "DNS convierte nombres de dominio en direcciones IP. Para diagnosticar fallos, comprueba la conexión, el servidor DNS y la resolución del dominio. Respuesta básica local, sin modelo LLM."
	if "wifi" in q or "wi-fi" in q or "red" in q:
		return "Empieza verificando IP, puerta de enlace, DNS y conexión con el router. Después comprueba interferencias y configuración. Respuesta básica local, sin modelo LLM."
	if "android" in q or "iphone" in q:
		return "Puedo ayudarte a organizar un diagnóstico del móvil. Indica el síntoma, versión del sistema y cuándo empezó. La IA avanzada aún no está integrada."
	if "linux" in q or "windows" in q:
		return "Para diagnosticar el sistema necesito el error exacto, la versión y los cambios recientes. La IA avanzada aún no está integrada."
	return "He guardado tu consulta. Esta V0.1 usa respuestas locales básicas y no incluye todavía un modelo de lenguaje. El siguiente módulo incorporará inferencia local real."

func _action(action: String) -> void:
	match action:
		"Investigar":
			current_task = (current_task + 1) % research_topics.size()
			_add_task("Estudiar " + research_topics[current_task])
			_append("SENTINEL", "Objetivo registrado: " + research_topics[current_task] + ". Investigación automatizada pendiente de integrar.")
		"Memoria":
			_append("SENTINEL", "Conversaciones guardadas: %d. Objetivos registrados: %d." % [history.size(), tasks.size()])
		"Estado":
			_append("SENTINEL", "Godot 3D activo. Memoria local activa. Motor LLM: pendiente. Servicio Android: pendiente. Supervisión: pendiente.")
		"Voz":
			voice_enabled = not voice_enabled
			_append("SENTINEL", "Voz " + ("activada" if voice_enabled else "desactivada") + ". La integración TTS Android está pendiente.")
	_update_status()

func _add_task(title: String) -> void:
	tasks.append({"title":title,"created":Time.get_unix_time_from_system(),"state":"pending"})
	_save_memory()

func _update_status() -> void:
	if status_label:
		status_label.text = "  LOCAL  |  %d objetivos  |  IA avanzada pendiente" % tasks.size()

func _save_memory() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"history":history,"tasks":tasks}))

func _load_memory() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		history = parsed.get("history", [])
		tasks = parsed.get("tasks", [])
