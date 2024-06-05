import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: _null__material
        objectName: "(null)"
        baseColor: "#ff999999"
        indexOfRefraction: 1
    }

    // Nodes:
    Node {
        id: tuomodesign_ethereum_obj
        objectName: "tuomodesign_ethereum.obj"
        Model {
            id: ethereum
            objectName: "Ethereum"
            source: "meshes/ethereum_mesh.mesh"
            materials: [
                _null__material
            ]
        }
    }

    // Animations:
}
