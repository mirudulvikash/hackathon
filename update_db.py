import sqlite3
import json

conn = sqlite3.connect('backend/munnarivu.db')
c = conn.cursor()

c.execute("UPDATE disasters SET short_description = 'Prepare for floods and learn how to stay safe during heavy rains.' WHERE id = 'd1'")
c.execute("UPDATE disasters SET short_description = 'Learn how to stay safe before, during and after an earthquake.' WHERE id = 'd2'")

c.execute("UPDATE disasters SET short_description = 'Be prepared for cyclones and follow safety guidelines during storms.', relevant_locations = ? WHERE id = 'd3'", (json.dumps(["Chennai", "Kanyakumari", "Coimbatore"]),))

c.execute("UPDATE disasters SET short_description = 'Understand landslide risks and learn how to stay safe in hilly areas.', relevant_locations = ? WHERE id = 'd4'", (json.dumps(["Nilgiris", "Coimbatore"]),))

c.execute("UPDATE disasters SET short_description = 'Understand fire safety measures and learn how to respond in case of fire.' WHERE id = 'd5'")
c.execute("UPDATE disasters SET short_description = 'Stay safe around electricity and learn lab safety procedures.' WHERE id = 'd6'")

conn.commit()
print('Database UI texts aligned fully!')
