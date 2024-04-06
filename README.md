# Rbx-PoissonDisc
A library for poisson-disc related tasks in Roblox

Note that when using some of the functions (other than those found in PoissonDisc.lua), if they return a table of points it may be flattened
(e.g. in the form { x, y, x1, y1, x2, y2, ... } rather than as a table of point tables { {x, y}, {x, y}, {x, y}, ... }

How I organize the scripts:

- I create a ModuleScript named "PointDistribution" and put it in ServerStorage under a Folder named "Algaerhythms".
  - I create three (3) ModuleScripts and set their Parent to PointDistribution:
    - Phyllotaxy
    - PoissonDisc
    - Tesselation
- I put Test scripts in ServerScriptService.

Examples:

PoissonDisc in Rectangle (with connection Visualizer):

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/b13a7846-7eb0-41ec-bd5f-05d109285d03)

PoissonDisc in Rectangle (no connection Visualizer):

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/e4422cd8-9ba9-474a-8e78-ef9b1d2380b8)


PoissonDisc in Rectangular Prism (3d) without connections shown:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/2d5c0fe5-6a7c-4503-8d43-a11e93db0295)

PoissonDisc in Rectangular Prism (3d) + connection Visualizer:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/f8ec8f8a-b8b6-4b42-a948-bd73ca8607b4)

ThreeThreeFourThreeFour tesselation in circle:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/89dee326-b6f2-4707-bfe5-a58679f8858a)

Ulam points in circle:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/e1618bb2-7c51-4a52-bf7f-f12d48d3cef4)

PhyllotaxicSpiral:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/a72c1833-c996-4db9-bdf8-f31e07b4fe13)

PolarPhyllotaxicSpiralsOnSphere:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/7c31f9a1-487a-41a4-8e87-b4d2f634a77e)

(Bonus) PoissonDisc being used for the placement of foliage:

![image](https://github.com/loamtor/Rbx-PoissonDisc/assets/118779491/1227d3d0-1be0-4a71-9ced-a01839a6db12)
