extends Node3D

const NAMES = ["Arda Demir","Mert Kaya","Emir Yılmaz","Kerem Arslan","Can Şahin","Eren Çelik","Bora Aydın","Yiğit Koç","Kaan Polat","Deniz Aksoy","Umut Güneş","Oğuz Öztürk","Ali Kaplan","Efe Doğan","Baran Kurt","Onur Aslan","Cem Tekin","Tuna Keskin","Furkan Ak","Serkan Deniz"]
var squad:Array=[]
var market:Array=[]
var cash:int=12500000
var week:int=1
var wins:int=0
var draws:int=0
var losses:int=0
var goals_for:int=0
var goals_against:int=0
var formation:String="4-3-3"
var tactic:String="Dengeli"
var opponent:String="İstanbul United"
var minute:int=0
var home_goals:int=0
var away_goals:int=0
var playing:bool=false
var tick:float=0.0
var rng=RandomNumberGenerator.new()
var panel:VBoxContainer
var heading:Label
var info:RichTextLabel
var status:Label
var players:Array[MeshInstance3D]=[]
var ball:MeshInstance3D

func _ready():
    rng.randomize()
    for i in range(20):
        squad.append({"name":NAMES[i],"pos":["KL","STP","STP","STP","MO","MO","MO","SĞK","SLK","ST"][i%10],"rating":rng.randi_range(61,78),"age":rng.randi_range(18,31),"value":rng.randi_range(400000,3200000),"fitness":100})
    for i in range(15):
        market.append({"name":" "+NAMES[rng.randi_range(0,19)]+" Jr","pos":["KL","STP","MO","KAN","ST"][i%5],"rating":rng.randi_range(60,82),"age":rng.randi_range(18,28),"value":rng.randi_range(500000,5000000)})
    _world()
    _ui()
    home()

func _world():
    var env=WorldEnvironment.new()
    var e=Environment.new()
    e.background_mode=Environment.BG_COLOR
    e.background_color=Color(0.025,0.04,0.03)
    env.environment=e
    add_child(env)
    var cam=Camera3D.new()
    cam.position=Vector3(0,58,65)
    cam.rotation_degrees=Vector3(-42,0,0)
    cam.current=true
    add_child(cam)
    var light=DirectionalLight3D.new()
    light.rotation_degrees=Vector3(-55,-25,0)
    add_child(light)
    _box(Vector3(92,0.2,60),Vector3.ZERO,Color(0.08,0.38,0.15))
    _box(Vector3(0.15,0.08,60),Vector3.ZERO,Color.WHITE)
    _box(Vector3(92,0.08,0.15),Vector3(0,0.15,-30),Color.WHITE)
    _box(Vector3(92,0.08,0.15),Vector3(0,0.15,30),Color.WHITE)
    for i in range(11):
        var p=_sphere(Vector3(-30+(i%4)*18,1.1,-20+(i/4)*20),Color(0.85,0.12,0.12))
        players.append(p)
    ball=_sphere(Vector3(0,0.8,0),Color.WHITE)

func _box(size:Vector3,pos:Vector3,col:Color):
    var n=MeshInstance3D.new()
    var m=BoxMesh.new()
    m.size=size
    n.mesh=m
    n.position=pos
    var mat=StandardMaterial3D.new()
    mat.albedo_color=col
    n.material_override=mat
    add_child(n)

func _sphere(pos:Vector3,col:Color)->MeshInstance3D:
    var n=MeshInstance3D.new()
    var m=SphereMesh.new()
    m.radius=1.0
    m.height=2.0
    n.mesh=m
    n.position=pos
    var mat=StandardMaterial3D.new()
    mat.albedo_color=col
    n.material_override=mat
    add_child(n)
    return n

func _ui():
    var layer=CanvasLayer.new()
    add_child(layer)
    var bg=ColorRect.new()
    bg.position=Vector2(850,0)
    bg.size=Vector2(430,720)
    bg.color=Color(0.015,0.025,0.02,0.96)
    layer.add_child(bg)
    var p=PanelContainer.new()
    p.position=Vector2(870,18)
    p.size=Vector2(390,684)
    layer.add_child(p)
    panel=VBoxContainer.new()
    panel.add_theme_constant_override("separation",7)
    p.add_child(panel)
    heading=Label.new()
    heading.add_theme_font_size_override("font_size",24)
    panel.add_child(heading)
    info=RichTextLabel.new()
    info.bbcode_enabled=true
    info.size_flags_vertical=Control.SIZE_EXPAND_FILL
    info.add_theme_font_size_override("normal_font_size",15)
    panel.add_child(info)
    status=Label.new()
    status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    panel.add_child(status)

func clear():
    for c in panel.get_children():
        if c!=heading and c!=info and c!=status:
            c.queue_free()

func btn(t:String,call:Callable):
    var b=Button.new()
    b.text=t
    b.custom_minimum_size.y=40
    b.pressed.connect(call)
    panel.add_child(b)

func home():
    clear()
    heading.text="KULÜP MERKEZİ"
    info.text="[b]Bursa FK[/b]  |  2026/27\nHafta: %d\nBütçe: €%s\n\nLig performansı\nOynanan: %d   G: %d   B: %d   M: %d\nAveraj: %d" % [week,str(cash),wins+draws+losses,wins,draws,losses,goals_for-goals_against]
    status.text="Yönetim paneli"
    btn("Kadro ve ilk 11",squad_screen)
    btn("Transfer pazarı",market_screen)
    btn("Taktik ve diziliş",tactics)
    btn("3D maç günü",match_screen)
    btn("Kariyeri kaydet",save_game)

func squad_screen():
    clear()
    heading.text="A TAKIMI"
    var s="[b]Oyuncu | Poz | GEN | Yaş | Değer[/b]\n"
    for p in squad:
        s+="%s | %s | %d | %d | €%s\n" % [p.name,p.pos,p.rating,p.age,str(p.value)]
    info.text=s
    status.text="Kadro"
    btn("Geri",home)

func market_screen():
    clear()
    heading.text="TRANSFER PAZARI"
    var s="Bütçe: €%s\n[b]No | Oyuncu | Poz | GEN | Fiyat[/b]\n" % str(cash)
    for i in range(market.size()):
        var p=market[i]
        s+="%d | %s | %s | %d | €%s\n" % [i+1,p.name,p.pos,p.rating,str(p.value)]
    info.text=s
    var entry=LineEdit.new()
    entry.placeholder_text="Transfer numarası"
    panel.add_child(entry)
    btn("Oyuncuyu transfer et",func(): buy(entry.text))
    btn("Geri",home)

func buy(raw:String):
    var i=int(raw)-1
    if i<0 or i>=market.size():
        status.text="Geçersiz oyuncu numarası"
        return
    var p=market[i]
    if p.value>cash:
        status.text="Bütçe yetersiz"
        return
    cash-=p.value
    squad.append(p)
    market.remove_at(i)
    market_screen()

func tactics():
    clear()
    heading.text="TAKTİK MERKEZİ"
    info.text="Diziliş: %s\nOyun planı: %s\n\nSeçimler maç simülasyonunu etkiler." % [formation,tactic]
    for f in ["4-3-3","4-2-3-1","3-5-2"]:
        btn("Diziliş "+f,func(): formation=f; tactics())
    for t in ["Dengeli","Pres","Kontra"]:
        btn("Plan "+t,func(): tactic=t; tactics())
    btn("Geri",home)

func match_screen():
    clear()
    heading.text="MAÇ GÜNÜ"
    info.text="Bursa FK - %s\n\nSkor: %d - %d\nDakika: %d'\n\nDiziliş: %s | Plan: %s\n\n3D saha üzerinde takımın hareketini izle." % [opponent,home_goals,away_goals,minute,formation,tactic]
    btn("Maçı başlat / duraklat",func(): playing=not playing; status.text="Maç oynanıyor" if playing else "Maç duraklatıldı")
    btn("Maçı bitir ve sonucu işle",finish_match)
    btn("Geri",home)

func _process(delta):
    if not playing:
        return
    tick+=delta
    for i in range(players.size()):
        var p=players[i]
        p.position.x=clamp(p.position.x+sin(tick*0.8+i)*delta*2,-43,43)
        p.position.z=clamp(p.position.z+cos(tick*0.7+i)*delta*2,-27,27)
    ball.position=Vector3(sin(tick)*18,0.8,cos(tick*0.7)*12)
    if tick>1.0:
        tick=0
        minute+=1
        if rng.randf()<0.025:
            home_goals+=1
        elif rng.randf()<0.02:
            away_goals+=1
        if minute>=90:
            playing=false
        if is_instance_valid(info):
            info.text="Bursa FK - %s\nSkor: %d - %d\nDakika: %d'\nDiziliş: %s | Plan: %s" % [opponent,home_goals,away_goals,minute,formation,tactic]

func finish_match():
    playing=false
    wins+=1 if home_goals>away_goals else 0
    draws+=1 if home_goals==away_goals else 0
    losses+=1 if home_goals<away_goals else 0
    goals_for+=home_goals
    goals_against+=away_goals
    cash+=250000 if home_goals>away_goals else 100000 if home_goals==away_goals else 0
    week+=1
    minute=0
    home_goals=0
    away_goals=0
    home()

func save_game():
    var f=FileAccess.open("user://career.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"squad":squad,"cash":cash,"week":week,"wins":wins,"draws":draws,"losses":losses}))
    status.text="Kariyer kaydedildi"
