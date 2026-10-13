# PyMOL Script for Figure 3: 3D Co-required Mutation Clustering
# Protein Structure: AF-I6XD65

# Set background and surface display
bg_color white
hide everything
show cartoon, all
color gray80, all

# Highlight co-required mutation positions
select mut_sites, resi 1+3+4+5+6+7+8+9+10+11+12+13+14+16+17+18+19+21+22+23+24+26+27+28+29+30+31+32+34+35+36+38+41+42+43+44+45+46+47+48+49+51+52+53+54+55+57+58+59+61+62+63+64+65+66+67+68+69+70+71+72+75+76+77+78+79+80+81+82+85+86+88+89+90+92+93+94+95+96+97+100+101+102+103+104+105+106+108+109+110+112+114+115+116+117+118+119+120+121+122+123+124+125+127+128+129+130+131+132+133+134+135+136+137+138+139+140+141+142+143+145+146+147+149+151+152+153+154+155+156+157+158+159+160+161+162+163+164+165+166+168+170+171+172+173+174+175+176+177+179+180+181+182+183+184+186
show spheres, mut_sites
color orange, mut_sites

# Set quality and camera perspective
set sphere_scale, 0.8
set ray_trace_mode, 1
set ray_shadow, 1
orient mut_sites
zoom mut_sites, 5

# Save high-resolution figure
png /content/drive/MyDrive/AMR_Structural_Mutation_Project/results/figures/figure3_pymol_3d_render.png, width=2400, height=1800, dpi=300
