p = r'C:\Users\Nishtha\Downloads\race-game-simple\Scene\Enemies\Enemy_Type_1_A.tscn'
s = open(p, encoding='utf-8').read()
if 'Enemy_Type_1_A.gd' not in s and 'id="2_gdscript"' not in s:
    s = s.replace(
        '[ext_resource type="Texture2D" uid="uid://n34l7pu1ypm8" path="res://Assests/Side View Assets JPG/Wraiths.png" id="1_tf5kf"]',
        '[ext_resource type="Texture2D" uid="uid://n34l7pu1ypm8" path="res://Assests/Side View Assets JPG/Wraiths.png" id="1_tf5kf"]\n'
        '[ext_resource type="Script" uid="uid://dptgx374mrptg" path="res://Scene/Enemies/Enemy_Type_1_A.gd" id="2_gdscript"]'
    )
start = s.find('[sub_resource type="GDScript"')
if start != -1:
    end = s.find('[sub_resource type="AtlasTexture"', start)
    if end != -1:
        s = s[:start] + s[end:]
s = s.replace('script = SubResource("GDScript_qn5lq")', 'script = ExtResource("2_gdscript")')
open(p, 'w', encoding='utf-8').write(s)
print('ok')
