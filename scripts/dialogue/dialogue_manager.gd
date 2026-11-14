extends Node

signal dialogue_started()
signal dialogue_line(speaker: String, text: String, avatar: String)
signal dialogue_ended()

var is_active: bool = false
var current_queue: Array = []
var current_line_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_dialogue(lines: Array) -> void:
	if lines.is_empty():
		return
	is_active = true
	current_queue = lines
	current_line_idx = 0
	dialogue_started.emit()
	_show_current_line()

func _show_current_line() -> void:
	if current_line_idx < current_queue.size():
		var data = current_queue[current_line_idx]
		var speaker = data.get("speaker", "???")
		var text = data.get("text", "")
		var avatar = data.get("avatar", "")
		dialogue_line.emit(speaker, text, avatar)
	else:
		end_dialogue()

func advance_dialogue() -> void:
	if not is_active:
		return
	current_line_idx += 1
	if current_line_idx < current_queue.size():
		_show_current_line()
	else:
		end_dialogue()

func end_dialogue() -> void:
	is_active = false
	current_queue.clear()
	current_line_idx = 0
	dialogue_ended.emit()
