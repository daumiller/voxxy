#version 330

uniform int voxel_x;
uniform int voxel_y;
uniform int voxel_z;
uniform int voxel_face;

out ivec4 FragColor;

void main() {
   FragColor = ivec4(voxel_x, voxel_y, voxel_z, voxel_face);
}
