import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    property url textureData: "maps/textureData.jpg"
    property url textureData7: "maps/textureData7.jpg"
    property url textureData9: "maps/textureData9.jpg"
    Texture {
        id: _0_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData
    }
    Texture {
        id: _1_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData7
    }
    Texture {
        id: _2_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData9
    }
    PrincipledMaterial {
        id: default_material
        objectName: "default"
        baseColorMap: _0_texture
        metalness: 0.10000000149011612
        roughness: 0.800000011920929
        normalMap: _1_texture
        occlusionMap: _2_texture
        alphaMode: PrincipledMaterial.Opaque
    }

    // Nodes:
    Model {
        id: spaceShuttle
        objectName: "SpaceShuttle"
        scale.x: 10
        scale.y: 10
        scale.z: 10
        source: "meshes/mesh_0_mesh.mesh"
        materials: [
            default_material
        ]
    }

    // Animations:
}
