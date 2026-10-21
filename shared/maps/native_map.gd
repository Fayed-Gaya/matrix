@tool
class_name MatrixNativeMap
extends Node2D
## Scene cells are the only map placement authority. The adapters preserve each
## game's original collision/animation rules instead of replacing its physics.

@export var grid_size: Vector2i = Vector2i(1, 1)


static func open(path: String) -> MatrixNativeMap:
	return (load(path) as PackedScene).instantiate() as MatrixNativeMap


func cell_bounds() -> Rect2i:
	var area: Rect2i = Rect2i(Vector2i.ZERO, grid_size)
	for child: Node in get_children():
		if child is TileMapLayer and not child.get_used_cells().is_empty():
			area = area.merge(child.get_used_rect())
	return area


func read_rows() -> Dictionary:
	var result: Dictionary = {}
	var area: Rect2i = cell_bounds()
	for child: Node in get_children():
		if not child is TileMapLayer or child.get_meta("preview_only", false):
			continue
		var rows: Array = []
		for y: int in range(area.size.y):
			var row: Array = []
			row.resize(area.size.x)
			row.fill(-1)
			rows.append(row)
		for cell: Vector2i in child.get_used_cells():
			var tile: TileData = child.get_cell_tile_data(cell)
			assert(tile != null, "Invalid native tile in " + scene_file_path)
			rows[cell.y - area.position.y][cell.x - area.position.x] = int(tile.get_custom_data("value"))
		result[String(child.name)] = rows
	return result


func paint_layer(canvas: CanvasItem, layer_name: String, camera_rect: Rect2) -> void:
	var layer: TileMapLayer = get_node(layer_name) as TileMapLayer
	if not layer.visible:
		return
	for cell: Vector2i in layer.get_used_cells():
		if Rect2(Vector2(cell * layer.tile_set.tile_size) - Vector2(256,256), Vector2(576,576)).intersects(camera_rect):
			paint_cell(canvas, layer_name, cell)


func paint_cell(canvas: CanvasItem, layer_name: String, cell: Vector2i) -> void:
	var layer: TileMapLayer = get_node(layer_name) as TileMapLayer
	var source_id: int = layer.get_cell_source_id(cell)
	if source_id < 0 or not layer.visible:
		return
	var source: TileSetAtlasSource = layer.tile_set.get_source(source_id) as TileSetAtlasSource
	var coords: Vector2i = layer.get_cell_atlas_coords(cell)
	var tile: TileData = layer.get_cell_tile_data(cell)
	var region: Rect2i = source.get_tile_texture_region(coords)
	var center: Vector2 = layer.map_to_local(cell) + layer.position
	var alternative: int = layer.get_cell_alternative_tile(cell)
	var cell_transpose: bool = bool(alternative & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	# Cell transforms compose after the authored alternative's transform.
	var flip_h: bool = (tile.flip_v if cell_transpose else tile.flip_h) != bool(alternative & TileSetAtlasSource.TRANSFORM_FLIP_H)
	var flip_v: bool = (tile.flip_h if cell_transpose else tile.flip_v) != bool(alternative & TileSetAtlasSource.TRANSFORM_FLIP_V)
	var transpose: bool = tile.transpose != bool(alternative & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var dimensions: Vector2 = Vector2(region.size)
	var origin: Vector2 = Vector2(tile.texture_origin)
	if transpose:
		dimensions = Vector2(dimensions.y,dimensions.x)
	# TileData's texture origin is already authored for its alternative. Only
	# per-cell transforms move that origin; combined flags orient the pixels.
	if alternative & TileSetAtlasSource.TRANSFORM_TRANSPOSE:
		origin = Vector2(origin.y,origin.x)
	if alternative & TileSetAtlasSource.TRANSFORM_FLIP_H:
		origin.x = -origin.x
	if alternative & TileSetAtlasSource.TRANSFORM_FLIP_V:
		origin.y = -origin.y
	# draw_texture_rect_region transposes the destination dimensions itself.
	var rect: Rect2 = Rect2(center-dimensions/2-origin,region.size)
	if flip_h:
		rect.size.x = -rect.size.x
	if flip_v:
		rect.size.y = -rect.size.y
	canvas.draw_texture_rect_region(source.texture, rect, region, layer.modulate * tile.modulate, transpose)


func read_monsters() -> Dictionary:
	var area: Rect2i = cell_bounds()
	var result: Dictionary = {"width": area.size.x, "height": area.size.y,
		"origin": [area.position.x, area.position.y], "tile_size": 64, "layers": [], "groups": {}}
	for child: Node in get_children():
		if child is TileMapLayer:
			var cells: Array = []
			cells.resize(area.size.x * area.size.y)
			cells.fill(0)
			for cell: Vector2i in child.get_used_cells():
				var tile: TileData = child.get_cell_tile_data(cell)
				cells[(cell.y-area.position.y)*area.size.x+cell.x-area.position.x] = int(tile.get_custom_data("value"))
			result.layers.append({"name": String(child.name), "cells": cells})
		elif child.name == "Groups":
			for group: Node in child.get_children():
				var entries: Array = []
				for marker: MatrixMapObject in group.get_children():
					entries.append(marker.descriptor())
				result.groups[String(group.name)] = entries
	return result
