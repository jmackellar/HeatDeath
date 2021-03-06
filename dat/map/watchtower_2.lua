return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.3",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 16,
  height = 23,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 47,
  nextobjectid = 40,
  properties = {},
  tilesets = {
    {
      name = "castletileset",
      firstgid = 1,
      filename = "castletileset.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../img/map/castletileset.png",
      imagewidth = 300,
      imageheight = 300,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 81,
      tiles = {}
    },
    {
      name = "tileset",
      firstgid = 82,
      filename = "tileset.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../img/map/tileset.png",
      imagewidth = 300,
      imageheight = 300,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 81,
      tiles = {
        {
          id = 30,
          properties = {
            ["walkPart"] = "waterstep"
          }
        },
        {
          id = 31,
          properties = {
            ["walkPart"] = "waterstep"
          }
        }
      }
    },
    {
      name = "dungeonFeatures",
      firstgid = 163,
      filename = "dungeonFeatures.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 10,
      image = "../img/map/dungeonFeatures.png",
      imagewidth = 320,
      imageheight = 320,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 100,
      tiles = {}
    },
    {
      name = "chambertileset",
      firstgid = 263,
      filename = "chambertileset.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../img/map/chambertileset.png",
      imagewidth = 300,
      imageheight = 300,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 81,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 31,
      name = "floor1",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 148, 41, 41, 41, 41, 41, 41, 148, 0, 0, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 0, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 0, 0, 0,
        0, 0, 0, 0, 303, 303, 303, 303, 303, 303, 303, 303, 0, 0, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 0, 0, 0,
        0, 0, 303, 41, 41, 303, 41, 41, 41, 41, 303, 41, 41, 303, 0, 0,
        0, 0, 303, 41, 41, 303, 41, 41, 41, 41, 303, 41, 41, 303, 0, 0,
        0, 0, 303, 41, 41, 303, 41, 41, 41, 41, 303, 41, 41, 303, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 303, 0, 0,
        0, 0, 0, 0, 303, 303, 303, 303, 303, 303, 303, 303, 0, 0, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 0, 0, 0,
        0, 0, 0, 0, 41, 303, 41, 41, 41, 41, 303, 41, 0, 0, 0, 0,
        0, 0, 0, 0, 148, 0, 41, 41, 41, 41, 303, 148, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 32,
      name = "floor2",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 157, 0, 157, 157, 157, 157, 0, 157, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 157, 0, 0, 0, 0, 157, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 157, 157, 0, 0, 0, 0, 0, 0, 0, 0, 157, 157, 0, 0,
        0, 0, 149, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 147, 0, 0,
        0, 0, 139, 139, 0, 0, 0, 0, 0, 0, 0, 0, 139, 139, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 0, 0, 0, 0, 0, 0, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 149, 139, 0, 0, 0, 0, 139, 147, 0, 0, 0, 0,
        0, 0, 0, 0, 139, 0, 139, 139, 139, 139, 0, 139, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 149, 147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 33,
      name = "floor3",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 149, 0, 0, 147, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 157, 0, 158, 0, 0, 156, 0, 157, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 149, 0, 158, 0, 0, 0, 0, 0, 0, 156, 0, 147, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 149, 0, 140, 0, 0, 0, 0, 0, 0, 138, 0, 147, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 139, 0, 140, 0, 0, 138, 0, 139, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 149, 0, 0, 147, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 34,
      name = "wall1",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 21, 0, 21, 22, 20, 21, 0, 21, 0, 0, 0, 0,
        0, 0, 0, 0, 21, 21, 21, 22, 20, 21, 21, 21, 0, 0, 0, 0,
        0, 0, 0, 0, 30, 21, 30, 31, 29, 30, 21, 30, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 30, 0, 0, 0, 0, 30, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 21, 21, 22, 0, 0, 0, 0, 0, 0, 20, 21, 21, 0, 0,
        0, 0, 21, 21, 22, 0, 0, 0, 0, 0, 0, 20, 21, 21, 0, 0,
        0, 0, 30, 30, 31, 0, 0, 0, 0, 0, 0, 29, 30, 30, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 35,
      name = "wall2",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 36,
      name = "wall3",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 168, 0, 168, 0, 0, 168, 0, 168, 0, 0, 0, 0,
        0, 0, 0, 0, 178, 0, 178, 0, 0, 178, 0, 178, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 46, 47, 0, 0, 0, 0, 0, 0, 0, 0, 46, 47, 0, 0,
        0, 0, 55, 56, 0, 0, 0, 0, 0, 0, 0, 0, 55, 56, 0, 0,
        0, 0, 64, 65, 0, 0, 0, 0, 0, 0, 0, 0, 64, 65, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 37,
      name = "ceiling1",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 143, 143, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 24, 32, 24, 25, 23, 24, 32, 24, 32, 32, 32, 32,
        32, 32, 32, 32, 23, 24, 25, 0, 0, 23, 24, 25, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 24, 24, 25, 0, 0, 0, 0, 0, 0, 23, 24, 24, 32, 32,
        32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32,
        32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32,
        32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32,
        32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32,
        32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32,
        32, 32, 32, 32, 168, 32, 168, 0, 0, 168, 32, 168, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 0, 0, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 144, 144, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
      }
    },
    {
      type = "tilelayer",
      id = 38,
      name = "ceiling2",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 14, 15, 15, 16, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 14, 15, 0, 15, 16, 14, 15, 0, 15, 16, 0, 0, 0,
        0, 0, 0, 0, 14, 15, 16, 0, 0, 14, 15, 16, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 14, 15, 15, 16, 0, 0, 0, 0, 0, 0, 14, 15, 15, 16, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 15, 15, 16, 0, 0, 0, 0, 0, 0, 14, 15, 15, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 14, 15, 16, 0, 0, 14, 15, 16, 0, 0, 0, 0,
        0, 0, 0, 0, 15, 0, 15, 16, 14, 15, 0, 15, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 15, 15, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 39,
      name = "ceiling3",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17, 18, 17, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 17, 18, 17, 18, 0, 0, 17, 18, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 18, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 0, 0, 0, 0, 0, 0, 17, 18, 0, 0, 0,
        0, 0, 0, 17, 18, 18, 18, 0, 0, 17, 17, 17, 18, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17, 18, 17, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17, 18, 17, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 40,
      name = "ceiling4",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 17, 18, 0, 0, 0, 0, 17, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 17, 17, 18, 0, 0, 0, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 41,
      name = "dropceil1",
      x = 0,
      y = 0,
      width = 16,
      height = 23,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 34, 0, 0, 0, 0, 0, 0, 0, 0, 33, 32, 32, 0,
        0, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      id = 42,
      name = "blockall",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "rectangle",
          x = 321.153,
          y = 180.003,
          width = 30.4923,
          height = 34.4268,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 288.693,
          y = 64.4273,
          width = 32.4595,
          height = 115.576,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 222.791,
          y = 41.3122,
          width = 65.9027,
          height = 23.1151,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 192.298,
          y = 41.3122,
          width = 30.4923,
          height = 139.183,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160.33,
          y = 180.495,
          width = 30.4923,
          height = 34.4268,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          type = "",
          shape = "rectangle",
          x = 129.346,
          y = 95.9032,
          width = 30.9841,
          height = 84.5916,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "",
          shape = "rectangle",
          x = 63.4437,
          y = 95.9032,
          width = 65.9027,
          height = 243.938,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "rectangle",
          x = 42.2958,
          y = 341.809,
          width = 20.6561,
          height = 104.756,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "",
          type = "",
          shape = "rectangle",
          x = 42.2958,
          y = 446.565,
          width = 86.067,
          height = 162.298,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "",
          shape = "rectangle",
          x = 128.363,
          y = 608.862,
          width = 31.9677,
          height = 13.7707,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160.33,
          y = 575.419,
          width = 32.4595,
          height = 47.2139,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "",
          shape = "rectangle",
          x = 192.79,
          y = 609.846,
          width = 31.9677,
          height = 62.9519,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224.758,
          y = 672.798,
          width = 62.46,
          height = 19.1806,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "",
          type = "",
          shape = "rectangle",
          x = 287.218,
          y = 607.879,
          width = 32.4595,
          height = 84.0997,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "",
          type = "",
          shape = "rectangle",
          x = 319.677,
          y = 574.927,
          width = 32.4595,
          height = 32.9514,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 17,
          name = "",
          type = "",
          shape = "rectangle",
          x = 351.645,
          y = 607.387,
          width = 33.935,
          height = 18.6888,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 18,
          name = "",
          type = "",
          shape = "rectangle",
          x = 385.58,
          y = 447.548,
          width = 62.46,
          height = 178.528,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "",
          type = "",
          shape = "rectangle",
          x = 448.04,
          y = 341.317,
          width = 28.0332,
          height = 106.231,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 20,
          name = "",
          type = "",
          shape = "rectangle",
          x = 383.613,
          y = 182.462,
          width = 92.4605,
          height = 158.855,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 21,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352.137,
          y = 96.395,
          width = 31.4759,
          height = 86.067,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 43,
      name = "mapinfo",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 22,
          name = "spawn",
          type = "",
          shape = "point",
          x = 252.814,
          y = 637.283,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 23,
          name = "tran1",
          type = "transition",
          shape = "rectangle",
          x = 222.188,
          y = 649.505,
          width = 65.9048,
          height = 17.6666,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "tran2",
            ["dx"] = 0,
            ["dy"] = -15,
            ["map"] = "watchtower_1"
          }
        },
        {
          id = 24,
          name = "dropceil1",
          type = "revealDrop",
          shape = "rectangle",
          x = 374.95,
          y = 254.697,
          width = 16.9114,
          height = 199.025,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 25,
          name = "dropceil1",
          type = "revealDrop",
          shape = "rectangle",
          x = 117.956,
          y = 252.13,
          width = 16.9114,
          height = 199.025,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 26,
          name = "dropceil1",
          type = "hideDrop",
          shape = "rectangle",
          x = 136.565,
          y = 252.13,
          width = 16.9114,
          height = 199.025,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 27,
          name = "dropceil1",
          type = "hideDrop",
          shape = "rectangle",
          x = 356.021,
          y = 254.697,
          width = 16.9114,
          height = 199.025,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 38,
          name = "watchtower",
          type = "world",
          shape = "point",
          x = 66.6046,
          y = -40.8222,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 39,
          name = "tran2",
          type = "transition",
          shape = "rectangle",
          x = 223.009,
          y = 65.591,
          width = 65.9048,
          height = 17.6666,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "tran1",
            ["dx"] = 0,
            ["dy"] = 15,
            ["map"] = "watchtower_3"
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 44,
      name = "light",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 28,
          name = "",
          type = "",
          shape = "point",
          x = 178.799,
          y = 562.853,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        },
        {
          id = 29,
          name = "",
          type = "",
          shape = "point",
          x = 338.442,
          y = 563.766,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        },
        {
          id = 30,
          name = "",
          type = "",
          shape = "point",
          x = 174.238,
          y = 401.387,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        },
        {
          id = 31,
          name = "",
          type = "",
          shape = "point",
          x = 339.354,
          y = 402.299,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        },
        {
          id = 32,
          name = "",
          type = "",
          shape = "point",
          x = 337.53,
          y = 260.901,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        },
        {
          id = 33,
          name = "",
          type = "",
          shape = "point",
          x = 176.975,
          y = 262.726,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.029999999999999999,
            ["green"] = 0.16,
            ["lightlevel"] = 7,
            ["red"] = 0.070000000000000007
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 46,
      name = "enemy",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 34,
          name = "watchtower_2_1",
          type = "normsword",
          shape = "point",
          x = 406.131,
          y = 355.473,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["dir"] = "west"
          }
        },
        {
          id = 35,
          name = "watchtower_2_2",
          type = "normsword",
          shape = "point",
          x = 103.481,
          y = 344.648,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["dir"] = "east"
          }
        },
        {
          id = 36,
          name = "watchtower_2_3",
          type = "normrapier",
          shape = "point",
          x = 103.048,
          y = 397.904,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["dir"] = "east"
          }
        },
        {
          id = 37,
          name = "watchtower_2_4",
          type = "normrapier",
          shape = "point",
          x = 407.43,
          y = 408.296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["dir"] = "west"
          }
        }
      }
    }
  }
}
