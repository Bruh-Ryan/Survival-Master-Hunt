p = r'C:\Users\Nishtha\Downloads\race-game-simple\Scene\Enemies\Enemy_Type_1_A.tscn'
s = open(p, encoding='utf-8').read()
if 'CapsuleShape2D_health' not in s:
    s = s.replace(
        'shape = SubResource("CapsuleShape2D_7s4v3")\n',
        'shape = SubResource("CapsuleShape2D_7s4v3")\n\n'
        '[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_health"]\n'
        'radius = 20.0\n'
        'height = 50.0\n\n'
    )
if '[node name="HEALTH"' not in s:
    s = s.replace(
        '[node name="Detect_Sphere"',
        '[node name="HEALTH" type="Area2D" parent="." unique_id=999001]\n\n'
        '[node name="HEALTH" type="CollisionShape2D" parent="HEALTH" unique_id=999002]\n'
        'shape = SubResource("CapsuleShape2D_health")\n\n'
        '[node name="Detect_Sphere"'
    )
if 'body_entered" from="HEALTH"' not in s:
    s += '[connection signal="body_entered" from="HEALTH" to="." method="_on_health_body_entered"]\n'
    s += '[connection signal="body_exited" from="HEALTH" to="." method="_on_health_body_exited"]\n'
open(p, 'w', encoding='utf-8').write(s)
print('ok2')
