class_name DataTres
extends Resource

func save_data(base_path: String) -> void:
	ResourceSaver.save(get_saved_path(base_path), self);

static func data_exists(base_path: String) -> bool:
	return ResourceLoader.exists(get_saved_path(base_path));

static func load_data(base_path: String) -> Resource:
	var saved_path: String = get_saved_path(base_path);
	if ResourceLoader.has_cached(saved_path):
		return ResourceLoader.load(saved_path, "", true);
	
	var file = File.new();
	if file.open(saved_path, File.READ) != OK:
		printerr("Can't read the file");
		return null;
	var data = file.get_buffer(file.get_len());
	file.close();
	
	var temporary_file_path = make_random_path();
	while ResourceLoader.has_cached(temporary_file_path):
		temporary_file_path = make_random_path()
	
	if file.open(temporary_file_path, File.WRITE) != OK:
		printerr("Can't write the file");
		return null;
	file.store_buffer(data);
	file.close();
	
	var saved_data = ResourceLoader.load(temporary_file_path, "", true);
	saved_data.take_over_path(saved_path);
	var directory = Directory.new();
	directory.remove(temporary_file_path);
	return saved_data;

static func make_random_path() -> String:
	return "user://temporary_file_" + str(randi()) + ".tres";

static func get_saved_path(base_path: String) -> String:
	var file_extension: String = ".tres" if OS.is_debug_build() else ".res";
	return base_path + file_extension;
