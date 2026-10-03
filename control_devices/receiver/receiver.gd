extends OLDControlDevice

func receive(control_signal: Array) -> void:
	if not is_control_signal(["transmitter", get_quadrant(position)], control_signal) or has_control_signal(control_signal): return;
	control_signals.append(control_signal); refresh();
	main.ui.do_power_supply(6);
	give_response();

func refresh() -> void:
	match control_signals.size():
		2:
			control("control_devices", [0], "active", true);
			control("control_devices", [1, 2], "active", false);
