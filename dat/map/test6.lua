return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.3",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 13,
  height = 15,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 33,
  nextobjectid = 36,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
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
      name = "crystalsheet",
      firstgid = 82,
      filename = "crystalsheet.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 10,
      image = "../img/map/crystalsheet.png",
      imagewidth = 332,
      imageheight = 332,
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
      name = "roadset",
      firstgid = 182,
      filename = "roadset.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../img/map/roadset.png",
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
    },
    {
      name = "carpetrunner",
      firstgid = 344,
      filename = "carpetrunner.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../img/map/carpetrunner.png",
      imagewidth = 300,
      imageheight = 260,
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
      tilecount = 72,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 23,
      name = "floor1",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 40, 40, 40, 40, 40, 0, 0, 0, 0, 0, 0,
        0, 303, 303, 303, 303, 303, 303, 40, 40, 0, 0, 0, 0,
        0, 303, 303, 303, 303, 303, 303, 303, 40, 40, 40, 40, 0,
        0, 303, 303, 40, 40, 40, 303, 303, 303, 303, 303, 303, 0,
        0, 303, 303, 40, 40, 40, 303, 303, 303, 303, 303, 303, 0,
        0, 303, 303, 40, 40, 40, 303, 303, 303, 303, 303, 303, 0,
        0, 303, 303, 40, 40, 40, 303, 303, 303, 303, 303, 303, 0,
        0, 303, 303, 303, 303, 303, 303, 303, 0, 0, 0, 0, 0,
        0, 0, 303, 303, 303, 303, 303, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 24,
      name = "floor2",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 57, 58, 58, 58, 59, 0, 0, 0, 0, 0, 0,
        0, 0, 66, 67, 67, 67, 68, 0, 0, 0, 0, 0, 0,
        0, 66, 67, 68, 76, 66, 67, 68, 0, 0, 0, 0, 0,
        0, 66, 67, 68, 0, 66, 67, 68, 199, 183, 183, 183, 0,
        0, 66, 67, 68, 0, 66, 67, 68, 0, 0, 0, 0, 0,
        0, 66, 67, 68, 58, 66, 67, 68, 0, 0, 0, 0, 0,
        0, 0, 66, 67, 67, 67, 68, 0, 0, 0, 0, 0, 0,
        0, 0, 75, 76, 76, 76, 77, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 25,
      name = "floor3",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 57, 58, 0, 0, 0, 58, 59, 0, 0, 0, 0, 0,
        0, 0, 0, 76, 0, 76, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 58, 0, 58, 0, 0, 0, 0, 0, 0, 0,
        0, 75, 76, 0, 0, 0, 76, 77, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 26,
      name = "wall1",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 283, 283, 283, 283, 283, 283, 0, 0, 0, 0, 0,
        0, 283, 283, 265, 265, 283, 265, 283, 283, 0, 0, 0, 0,
        0, 283, 292, 292, 292, 292, 292, 283, 283, 283, 283, 283, 0,
        0, 292, 0, 47, 0, 47, 0, 292, 283, 265, 283, 283, 0,
        0, 0, 64, 0, 0, 0, 64, 0, 292, 292, 292, 292, 0,
        0, 0, 47, 57, 0, 59, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 75, 0, 77, 0, 0, 361, 345, 345, 345, 0,
        0, 0, 47, 57, 0, 59, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 75, 0, 77, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 65, 47, 0, 47, 65, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 27,
      name = "wall2",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 316, 0, 314, 316, 315, 0, 0, 0, 0, 0, 0,
        0, 316, 0, 0, 0, 0, 0, 0, 315, 0, 0, 0, 0,
        0, 0, 296, 297, 298, 0, 296, 0, 0, 314, 0, 0, 0,
        0, 297, 305, 306, 307, 0, 305, 297, 0, 0, 0, 0, 0,
        0, 306, 0, 0, 0, 0, 0, 306, 0, 298, 296, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 307, 305, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 325, 324, 0, 0, 0,
        0, 323, 0, 0, 0, 0, 0, 324, 0, 0, 0, 0, 0,
        0, 0, 324, 296, 325, 324, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 28,
      name = "wall3",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 315, 316, 0, 0,
        0, 0, 293, 0, 0, 0, 291, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 291, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 29,
      name = "ceiling1",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
        72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
        72, 72, 286, 286, 286, 286, 286, 286, 72, 72, 72, 72, 72,
        72, 286, 287, 0, 0, 0, 0, 285, 286, 72, 72, 72, 72,
        72, 0, 0, 0, 0, 0, 0, 0, 285, 286, 286, 286, 72,
        72, 0, 55, 0, 0, 0, 55, 0, 0, 0, 0, 0, 72,
        72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72,
        72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72,
        72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72,
        72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72,
        72, 0, 56, 0, 0, 0, 56, 0, 0, 0, 56, 0, 72,
        72, 0, 0, 0, 0, 0, 0, 285, 72, 72, 72, 72, 72,
        72, 72, 287, 0, 0, 0, 285, 72, 72, 72, 72, 72, 72,
        72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
        72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72
      }
    },
    {
      type = "tilelayer",
      id = 30,
      name = "ceiling2",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 276, 277, 277, 277, 277, 277, 277, 278, 0, 0, 0, 0,
        276, 277, 278, 0, 0, 0, 0, 276, 277, 278, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 276, 277, 277, 277, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 276, 277, 277, 277, 277, 0,
        276, 277, 278, 0, 0, 0, 276, 277, 278, 0, 0, 0, 0,
        0, 276, 277, 277, 277, 277, 277, 278, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 31,
      name = "ceiling3",
      x = 0,
      y = 0,
      width = 13,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 279, 280, 0, 0, 0, 0, 279, 280, 0, 0, 0, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 279, 280, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0,
        279, 280, 0, 0, 0, 0, 0, 279, 280, 0, 0, 54, 0,
        0, 279, 280, 0, 0, 0, 279, 280, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      id = 11,
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
          x = 256.345,
          y = 182.317,
          width = 127.339,
          height = 32.8515,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224.432,
          y = 147.588,
          width = 31.9129,
          height = 34.7287,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 62.99,
          y = 128.19,
          width = 161.442,
          height = 19.398,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32.016,
          y = 128.19,
          width = 30.9743,
          height = 55.6911,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "",
          shape = "rectangle",
          x = 22.317,
          y = 183.881,
          width = 9.69902,
          height = 199.299,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          type = "",
          shape = "rectangle",
          x = 22.317,
          y = 383.181,
          width = 43.802,
          height = 34.103,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "",
          shape = "rectangle",
          x = 66.119,
          y = 417.284,
          width = 158.313,
          height = 11.5762,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224.432,
          y = 383.493,
          width = 31.9129,
          height = 45.3664,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "",
          type = "",
          shape = "rectangle",
          x = 256.345,
          y = 352.206,
          width = 133.909,
          height = 31.2872,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "",
          shape = "rectangle",
          x = 382.745,
          y = 210.475,
          width = 4.3802,
          height = 142.669,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "",
          type = "",
          shape = "rectangle",
          x = 323,
          y = 335.749,
          width = 26.4976,
          height = 20.2517,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "",
          shape = "rectangle",
          x = 200.164,
          y = 349.755,
          width = 15.52,
          height = 7.94928,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "",
          type = "",
          shape = "rectangle",
          x = 71.84,
          y = 350.701,
          width = 15.52,
          height = 7.94928,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "",
          type = "",
          shape = "rectangle",
          x = 71.651,
          y = 190.39,
          width = 15.52,
          height = 7.94928,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "",
          type = "",
          shape = "rectangle",
          x = 200.543,
          y = 190.58,
          width = 15.52,
          height = 7.94928,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 16,
          name = "",
          type = "",
          shape = "rectangle",
          x = 174.235,
          y = 174.303,
          width = 4.73171,
          height = 8.13854,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 17,
          name = "",
          type = "",
          shape = "rectangle",
          x = 110.167,
          y = 173.262,
          width = 4.73171,
          height = 8.13854,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 18,
          name = "",
          type = "",
          shape = "rectangle",
          x = 78.465,
          y = 238.086,
          width = 4.35317,
          height = 7.94928,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "",
          type = "",
          shape = "rectangle",
          x = 78.465,
          y = 302.816,
          width = 4.35317,
          height = 8.13854,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 20,
          name = "",
          type = "",
          shape = "rectangle",
          x = 110.262,
          y = 366.221,
          width = 4.54244,
          height = 8.13854,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 21,
          name = "",
          type = "",
          shape = "rectangle",
          x = 174.613,
          y = 366.41,
          width = 4.35317,
          height = 8.13854,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 32,
      name = "item",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 35,
          name = "photonicflask",
          type = "key",
          shape = "point",
          x = 292.745,
          y = 243.295,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["item"] = "photonicflask",
            ["itemType"] = "items"
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 12,
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
          x = 140.028,
          y = 266.866,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 31,
          name = "tran1",
          type = "transition",
          shape = "rectangle",
          x = 364.738,
          y = 177.551,
          width = 18.0776,
          height = 174.177,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "tran2",
            ["dx"] = -19,
            ["dy"] = 0,
            ["map"] = "test5"
          }
        },
        {
          id = 32,
          name = "birthchamber",
          type = "world",
          shape = "point",
          x = 3.5,
          y = 36.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 13,
      name = "light",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 23,
          name = "",
          type = "",
          shape = "point",
          x = 254.76,
          y = 294.503,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.059999999999999998,
            ["green"] = 0.23999999999999999,
            ["lightlevel"] = 9,
            ["red"] = 0.23999999999999999
          }
        },
        {
          id = 25,
          name = "",
          type = "",
          shape = "point",
          x = 176.278,
          y = 178.543,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 26,
          name = "",
          type = "",
          shape = "point",
          x = 112.861,
          y = 178.082,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 27,
          name = "",
          type = "",
          shape = "point",
          x = 80.807,
          y = 242.652,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 28,
          name = "",
          type = "",
          shape = "point",
          x = 80.312,
          y = 305.477,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 29,
          name = "",
          type = "",
          shape = "point",
          x = 112.372,
          y = 370.461,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 30,
          name = "",
          type = "",
          shape = "point",
          x = 175.997,
          y = 370.461,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.29999999999999999,
            ["green"] = 0.050000000000000003,
            ["lightlevel"] = 8,
            ["red"] = 0.050000000000000003
          }
        },
        {
          id = 34,
          name = "",
          type = "",
          shape = "point",
          x = 252.627,
          y = 224.14,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["blue"] = 0.059999999999999998,
            ["green"] = 0.23999999999999999,
            ["lightlevel"] = 9,
            ["red"] = 0.23999999999999999
          }
        }
      }
    }
  }
}
