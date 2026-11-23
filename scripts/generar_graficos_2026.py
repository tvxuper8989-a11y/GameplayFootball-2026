#!/usr/bin/env python3
"""Genera graficos CONCEPTUALES 2026/27, no replicas oficiales. No modifica data/."""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw

BALLS = {
    "nike_control_concept": ("#F5F7F4", "#86EB18", "#1B2131"),
    "puma_stellar_concept": ("#F3F4F5", "#E547A5", "#30316C"),
    "adidas_starlight_concept": ("#ECECF8", "#159DEB", "#15204D"),
    "neutral": ("#F7F7F7", "#151925", "#50586B"),
}
BOOTS = {
    "nike_mercurial": ("#F0502F","#181B26"),
    "nike_phantom": ("#11C4E7","#102B40"),
    "nike_tiempo": ("#EDE5DB","#1B283A"),
    "adidas_predator": ("#C71838","#111C2C"),
    "adidas_f50": ("#E8FB24","#0C2642"),
    "adidas_copa": ("#E6DDC8","#232F41"),
    "puma_future": ("#8B5CE7","#00DDD2"),
    "puma_ultra": ("#C5F223","#152B42"),
    "puma_king": ("#111A29","#DFC07C"),
}
CLUBS = {
    "fcbarcelona": ("#153283","#91274C"),
    "realmadrid": ("#F3F0E9","#CDB379"),
    "arsenal": ("#CA1736","#FAFAFA"),
    "manchesterunited": ("#D51E3F","#131D2B"),
    "bayernmunich": ("#D81733","#FBFAF6"),
    "borussiadortmund": ("#F1DF23","#14202E"),
    "afcajax": ("#FAF8F4","#C61A35"),
    "psv": ("#CE1A36","#F8F7F4"),
}
HAIR={"black":"#15191F","brown":"#67503A","blonde":"#C3A46C",
      "darkblonde":"#977C60","red":"#963C31"}

def rgb(h):
    h=h.lstrip("#")
    return tuple(int(h[i:i+2],16) for i in (0,2,4))

def write_image(root,name,image):
    path=root/name
    path.parent.mkdir(parents=True,exist_ok=True)
    image.save(path)
    return name

def ball_image(colors):
    bg,a,b=map(rgb,colors)
    im=Image.new("RGB",(1024,512),bg)
    d=ImageDraw.Draw(im)
    for y in range(-60,540,76):
        for x in range(-120,1100,134):
            d.polygon([(x,y),(x+97,y+7),(x+126,y+40),(x+100,y+68),(x,y+60)],outline=b,width=5)
            d.line([(x+13,y+22),(x+57,y+42),(x+100,y+20)],fill=a,width=15)
    return im

def boot_image(colors):
    im=Image.new("RGB",(512,512),rgb(colors[0]))
    d=ImageDraw.Draw(im)
    for n in range(-3,24):
        y=n*27
        d.line([(0,y),(240,y+95),(512,y+24)],fill=rgb(colors[1]),width=7)
    for n in range(5):d.line((165+n*20,115,201+n*20,180),fill="white",width=5)
    return im

def kit_image(original,primary,secondary,variant):
    im=Image.new("RGBA",original.size,rgb(primary)+(255,))
    d=ImageDraw.Draw(im)
    w,h=im.size
    pitch=max(24,w//12)
    if variant in ("01","04"):
        for x in range(0,w,pitch):
            if x//pitch%2==0:d.rectangle((x,0,x+pitch//2,h),fill=rgb(secondary)+(255,))
    elif variant=="03":
        for x in range(-w,w*2,w//5):
            d.polygon([(x,0),(x+w//7,0),(x+w//2,h),(x+w//2-w//7,h)],fill=rgb(secondary)+(255,))
    else:
        d.rectangle((0,0,w//20,h),fill=rgb(secondary)+(255,))
        d.rectangle((w-w//20,0,w,h),fill=rgb(secondary)+(255,))
    im.putalpha(original.convert("RGBA").getchannel("A"))
    return im

def scoreboard(main,accent):
    im=Image.new("RGBA",(1024,64),(0,0,0,0))
    d=ImageDraw.Draw(im)
    d.rounded_rectangle((0,2,1020,61),radius=12,fill=rgb(main)+(242,))
    d.rounded_rectangle((0,2,91,61),radius=12,fill=rgb(accent)+(255,))
    for x in (260,520,790):d.rectangle((x,10,x+4,53),fill=rgb(accent)+(255,))
    return im

def face_fallback(shade):
    palette=[(237,184,137),(206,153,111),(150,101,80),(98,62,49)]
    im=Image.new("RGBA",(256,256),(13,21,36,255))
    d=ImageDraw.Draw(im)
    d.ellipse((51,20,205,225),fill=palette[shade])
    d.ellipse((74,107,95,119),fill=(19,24,32))
    d.ellipse((163,107,184,119),fill=(19,24,32))
    d.arc((100,145,162,181),0,165,fill=(75,43,39),width=4)
    return im

def make(source,output):
    source=Path(source).resolve();output=Path(output).resolve()
    if source==output or source in output.parents or output in source.parents:
        raise ValueError("Destinar el overlay fuera de la carpeta data/ original")
    model=source/"media/objects/balls/generic.ase"
    descriptor=source/"media/objects/balls/generic.object"
    if not model.is_file() or not descriptor.is_file():
        raise ValueError("Falta modelo generico de pelota")
    mesh=model.read_text(encoding="utf-8")
    obj=descriptor.read_text(encoding="utf-8")
    if "media/objects/balls/ball.jpg" not in mesh or "generic.ase" not in obj:
        raise ValueError("Modelo ASE original no reconocido")
    assets=[]
    for name,colors in BALLS.items():
        path="media/objects/balls/edition2026/"+name
        tex=path+".png"
        assets.append(write_image(output,tex,ball_image(colors)))
        (output/(path+".ase")).write_text(mesh.replace("media/objects/balls/ball.jpg",tex),encoding="utf-8")
        (output/(path+".object")).write_text(obj.replace("generic.ase",name+".ase"),encoding="utf-8")
        assets.extend([path+".ase",path+".object"])
    for name,colors in BOOTS.items():
        assets.append(write_image(output,"media/objects/players/textures/boots2026/"+name+".png",boot_image(colors)))
    for name,a,b in [("dark","#0D203F","#00E4DE"),("magenta","#2C1239","#E76ABB"),("blue","#143868","#D5C06C")]:
        assets.append(write_image(output,"media/menu/scoreboards2026/"+name+".png",scoreboard(a,b)))
    for index in range(4):
        assets.append(write_image(output,"media/objects/players/faces2026/fallback_0"+str(index+1)+".png",face_fallback(index)))
    for name,c in HAIR.items():
        im=Image.new("RGB",(256,256),rgb(c))
        d=ImageDraw.Draw(im)
        for x in range(0,256,11):
            for y in range(0,256,17):d.arc((x,y,x+20,y+12),180,340,fill="#C2A281",width=1)
        assets.append(write_image(output,"media/objects/players/textures/hair/"+name+".png",im))
    clubs=0
    for original in sorted((source/"databases/default/images_teams").glob("*/*_kit_01.png")):
        team=original.stem.removesuffix("_kit_01")
        base,secondary=CLUBS.get(team,("#e7e7e7","#15243c"))
        uv=Image.open(original)
        for slot,a,b in (("01",base,secondary),("02",secondary,base),("03","#102748","#00CED1"),("04","#F1E9D8","#152D48"),("gk","#247D63","#E7D59B")):
            suffix="_kit_gk.png" if slot=="gk" else "_kit_"+slot+".png"
            rel="databases/default/images_teams/"+original.parent.name+"/"+team+suffix
            assets.append(write_image(output,rel,kit_image(uv,a,b,slot)))
        clubs+=1
    for name,base,accent in (("cyan","#112F46","#21DBE2"),("gold","#1A2447","#E9C979")):
        im=Image.new("RGB",(1024,128),rgb(base));d=ImageDraw.Draw(im)
        for x in range(0,1100,90):d.polygon([(x,128),(x+40,0),(x+75,0),(x+35,128)],fill=rgb(accent))
        assets.append(write_image(output,"media/textures/adboards/season2026_"+name+".png",im))
    im=Image.new("RGB",(1280,1024),(4,17,35))
    d=ImageDraw.Draw(im)
    d.ellipse((-80,90,1360,940),outline=(30,96,144),width=55)
    d.ellipse((25,250,1255,870),outline=(12,26,43),width=130)
    d.polygon([(170,770),(1100,770),(1270,1024),(0,1024)],fill=(22,91,59))
    for x in range(130,1180,92):d.ellipse((x,230,x+25,252),fill=(221,244,255))
    assets.append(write_image(output,"media/menu/backgrounds/intro01.png",im))
    config='''"context_x" "1280"
"context_y" "720"
"context_fullscreen" "false"
"graphics3d_frametime_ms" "33"
"ball_object" "media/objects/balls/edition2026/puma_stellar_concept.object"
"boot_texture" "media/objects/players/textures/boots2026/adidas_f50.png"
"scoreboard_background" "media/menu/scoreboards2026/dark.png"
"stadium_object" "media/objects/stadiums/test/test.object"
'''
    (output/"football_graficos_2026_27.config").write_text(config,encoding="utf-8")
    manifest={"season":"2026/27","type":"original_concepts_not_official","clubs":clubs,"files":sorted(assets)}
    (output/"CATALOGO_GENERADO.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
    print("OK",len(assets),"archivos",clubs,"clubes")
    return manifest

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--source",type=Path,default=Path("data"))
    p.add_argument("--output",type=Path,default=Path("build_assets_2026_27"))
    a=p.parse_args();make(a.source,a.output)
