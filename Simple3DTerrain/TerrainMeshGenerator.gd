extends MeshInstance

const mapScale := 0.2
const mapHeight := 50.0

export var heightmap : Texture

var colors := [Color.blue, Color.darkgreen, Color.red, Color.white]
var surfaceTool := SurfaceTool.new()

onready var mapWidth := heightmap.get_width()
onready var mapLength := heightmap.get_height()

func _ready() -> void:
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	SetMaterial()
	SetUpVertices()
	SetUpIndices()
	
	surfaceTool.generate_normals()
	
	var tempMesh := Mesh.new()
	surfaceTool.commit(tempMesh)
	mesh = tempMesh

func SetUpVertices() -> void:
	var vertices := PoolVector3Array()
	
	var heightmap_image := heightmap.get_data()
	heightmap_image.lock()
	
	for x in mapWidth:
		for z in mapLength:
			var color := heightmap_image.get_pixel(z, x)
			var height := (color.r + color.g + color.b) / 3.0
			var vertexPosition := Vector3(z * mapScale, height * mapHeight * mapScale, x * mapScale);
			vertexPosition.x -= mapWidth * 0.5 * mapScale
			vertexPosition.z -= mapLength * 0.5 * mapScale
			vertices.append(vertexPosition)
	
	var high : float = 0.0
	var low : float = mapHeight * mapScale
	
	for i in vertices.size():
		if vertices[i].y > high:
			high = vertices[i].y
		if vertices[i].y < low:
			low = vertices[i].y
	
	var height : float = high - low
	
	for i in vertices.size():
		# Set Color
		if vertices[i].y < low + height * 0.25:
			surfaceTool.add_color(colors[0])
		elif vertices[i].y < low + height * 0.5:
			surfaceTool.add_color(colors[1])
		elif vertices[i].y < low + height * 0.75:
			surfaceTool.add_color(colors[2])
		else:
			surfaceTool.add_color(colors[3]) 
		
		# Create Vertex
		surfaceTool.add_vertex(vertices[i])

func SetUpIndices() -> void:
	var indices := PoolIntArray()
	
	var counter := 0
	for z in mapLength:
		for x in mapWidth:
			# Triangle 1
			indices.append(counter + mapLength) # Lower Left
			indices.append(counter) # Upper Left
			indices.append(counter + 1) # Upper Right
			
			# Triangle 2
			indices.append(counter + 1) # Upper Right
			indices.append(counter + mapLength + 1) # Lower Right
			indices.append(counter + mapLength) # Lower Left
			
			counter += 1
			
			# Skip if the next vertex is at the edge.
			if x + 2 >= mapWidth:
				counter += 1
				break
		
		# Skip if the next vertex is at the edge.
		if z + 2 >= mapLength:
			break
	
	for i in indices.size():
		surfaceTool.add_index(indices[i])

func SetMaterial() -> void:
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color.white
	mat.params_cull_mode = SpatialMaterial.CULL_BACK
	mat.vertex_color_use_as_albedo = true
	mat.flags_vertex_lighting = true
	surfaceTool.set_material(mat)
