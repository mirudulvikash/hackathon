import '../../models/quiz_model.dart';

final List<QuizQuestion> mockQuizQuestions = [
  // FLOOD (d1)
  const QuizQuestion(
    id: 'q1_d1',
    disasterId: 'd1',
    question: 'When a flood warning is issued, what is the best immediate action for someone living in a low-lying area?',
    options: [
      'Hide safely in the basement.',
      'Wait for water to enter your home before leaving.',
      'Evacuate immediately to higher ground.',
      'Drive your car through flooded roads to escape.'
    ],
    correctOptionIndex: 2,
    explanation: 'Always evacuate to higher ground immediately. Basements flood first, and driving through water can be fatal as vehicles can be swept away easily.',
  ),
  const QuizQuestion(
    id: 'q2_d1',
    disasterId: 'd1',
    question: 'If you must walk during a flood evacuation and you see moving water across your path, what should you do?',
    options: [
      'Run quickly through it.',
      'Stop, turn around, and go another way.',
      'Hold onto a tree and wade through.',
      'Walk slowly so you don\'t slip.'
    ],
    correctOptionIndex: 1,
    explanation: 'Turn around! Even 6 inches of fast-moving water can knock an adult off their feet.',
  ),
  const QuizQuestion(
    id: 'q3_d1',
    disasterId: 'd1',
    question: 'Why is it important not to use electrical appliances directly after a flood?',
    options: [
      'To save electricity.',
      'Because they might be wet and cause fatal electric shocks.',
      'Because they will be too dirty to use.',
      'Water damage makes them consume more power.'
    ],
    correctOptionIndex: 1,
    explanation: 'Water is a strong conductor of electricity. Using wet appliances or standing in water while touching switches can cause immediate electrocution.',
  ),
  const QuizQuestion(
    id: 'q4_d1',
    disasterId: 'd1',
    question: 'What is the safest source of drinking water following a severe flood?',
    options: [
      'Well water.',
      'Boiled rainwater.',
      'Tap water directly from the sink.',
      'Bottled water.'
    ],
    correctOptionIndex: 3,
    explanation: 'Bottled water is safest. Floods often contaminate local water supplies, rendering tap and well water extremely hazardous until officially declared safe.',
  ),

  // EARTHQUAKE (d2)
  const QuizQuestion(
    id: 'q1_d2',
    disasterId: 'd2',
    question: 'During an earthquake indoors, what is the safest immediate action?',
    options: [
      'Run outside quickly.',
      'Stand in a doorway.',
      'Drop, Cover, and Hold On under a sturdy table.',
      'Run to the top floor of the building.'
    ],
    correctOptionIndex: 2,
    explanation: 'Drop, Cover, and Hold On! Running outside or standing in a doorway exposes you to falling debris and flying glass.',
  ),
  const QuizQuestion(
    id: 'q2_d2',
    disasterId: 'd2',
    question: 'If you are outside when an earthquake strikes, you should:',
    options: [
      'Move away from buildings, wires, and streetlights.',
      'Run into the nearest building for shelter.',
      'Stand under a large tree for protection.',
      'Lie down on the road.'
    ],
    correctOptionIndex: 0,
    explanation: 'Move to an open area away from anything that can fall on you, such as buildings, trees, and power lines.',
  ),
  const QuizQuestion(
    id: 'q3_d2',
    disasterId: 'd2',
    question: 'What should you expect directly following a major earthquake?',
    options: [
      'Heavy rainfall.',
      'Aftershocks.',
      'Complete silence.',
      'A change in the local weather pattern.'
    ],
    correctOptionIndex: 1,
    explanation: 'Always anticipate aftershocks following a major earthquake, which can cause further damage to already weakened structures.',
  ),
  const QuizQuestion(
    id: 'q4_d2',
    disasterId: 'd2',
    question: 'If you are driving and feel an earthquake, what is your safest response?',
    options: [
      'Accelerate out of the area.',
      'Brake suddenly in the middle of traffic.',
      'Stop by the side of the road safely and stay in the car.',
      'Abandon the car and run.'
    ],
    correctOptionIndex: 2,
    explanation: 'Pull over quickly but safely, avoiding overpasses or power lines. Staying inside the vehicle protects you from falling debris.',
  ),

  // CYCLONE (d3)
  const QuizQuestion(
    id: 'q1_d3',
    disasterId: 'd3',
    question: 'When the wind suddenly completely dies down during a cyclone, what is likely happening?',
    options: [
      'The storm is permanently over.',
      'The "eye" of the cyclone is passing over you.',
      'The wind has changed direction to go back out to sea.',
      'Atmospheric pressure returned to normal.'
    ],
    correctOptionIndex: 1,
    explanation: 'This is the "Eye" of the storm. It is a false calm. Severe winds will return suddenly from the opposite direction. Remain sheltered!',
  ),
  const QuizQuestion(
    id: 'q2_d3',
    disasterId: 'd3',
    question: 'Why should you proactively tape or board up windows before a cyclone?',
    options: [
      'To prevent rain from making the house dirty.',
      'To reduce heat loss.',
      'To prevent glass from shattering inward due to flying debris and pressure.',
      'To block out the noise of the storm.'
    ],
    correctOptionIndex: 2,
    explanation: 'High-speed winds turn loose objects into lethal projectiles. Boarding windows helps prevent hazardous shattered glass injuries indoors.',
  ),
  const QuizQuestion(
    id: 'q3_d3',
    disasterId: 'd3',
    question: 'What should be your primary reliable source of information during a cyclone?',
    options: [
      'Social media rumors.',
      'Word of mouth from neighbors.',
      'Battery-operated radio tuned to local emergency stations.',
      'Watching the sky.'
    ],
    correctOptionIndex: 2,
    explanation: 'Power lines break during cyclones, and internet/cellular networks often fail. A battery-powered radio ensures you receive official alerts.',
  ),
  const QuizQuestion(
    id: 'q4_d3',
    disasterId: 'd3',
    question: 'After a cyclone, why is it advised to use SMS rather than making phone calls?',
    options: [
      'Calling drains battery faster than SMS.',
      'SMS text uses less network bandwidth, leaving phone lines open for emergencies.',
      'Phone lines are usually completely destroyed.',
      'SMS provides better GPS tracking.'
    ],
    correctOptionIndex: 1,
    explanation: 'In the aftermath, cellular towers are overwhelmed. Using SMS requires much less network bandwidth and helps keep lines free for emergency operators.',
  ),

  // LANDSLIDE (d4)
  const QuizQuestion(
    id: 'q1_d4',
    disasterId: 'd4',
    question: 'Which visual cue could indicate an impending landslide?',
    options: [
      'Grass growing rapidly.',
      'Trees, fences, or utility poles suddenly tilting.',
      'Large groups of birds flying away.',
      'A drop in local temperature.'
    ],
    correctOptionIndex: 1,
    explanation: 'If trees or poles begin leaning, it means the deeper soil beneath them is shifting downwards, signaling a potential landslide.',
  ),
  const QuizQuestion(
    id: 'q2_d4',
    disasterId: 'd4',
    question: 'If you are caught in the direct path of a landslide and cannot escape, what is the best defensive posture?',
    options: [
      'Stand tall with your arms out.',
      'Run directly towards the sliding dirt.',
      'Curl into a tight ball and protect your head.',
      'Lie completely flat on your stomach.'
    ],
    correctOptionIndex: 2,
    explanation: 'Curling into a tight ball protects your most vital organ—your head/brain—from impact by rocks and debris.',
  ),
  const QuizQuestion(
    id: 'q3_d4',
    disasterId: 'd4',
    question: 'What weather condition most commonly triggers landslides?',
    options: [
      'Extreme Heatwaves.',
      'Prolonged Heavy Rainfall.',
      'Dense fog.',
      'High wind speeds alone.'
    ],
    correctOptionIndex: 1,
    explanation: 'Heavy water saturates soil, increasing its weight and reducing internal friction, causing entire slopes of earth to collapse.',
  ),
  const QuizQuestion(
    id: 'q4_d4',
    disasterId: 'd4',
    question: 'What is a dangerous post-landslide action?',
    options: [
      'Staying away from the slide zone.',
      'Returning immediately to check on your property.',
      'Tuning into emergency broadcasts.',
      'Reporting broken utility lines.'
    ],
    correctOptionIndex: 1,
    explanation: 'Never return to a slide area immediately. Secondary landslides often occur following the same path shortly after the first.',
  ),

  // FIRE ACCIDENTS (d5)
  const QuizQuestion(
    id: 'q1_d5',
    disasterId: 'd5',
    question: 'If a fire alarm sounds in a multistory building, what is a critical mistake to avoid?',
    options: [
      'Using the stairs to exit.',
      'Using the elevator to escape quickly.',
      'Feeling doors for heat before opening.',
      'Leaving your belongings behind.'
    ],
    correctOptionIndex: 1,
    explanation: 'Never use an elevator during a fire! Power can fail, trapping you inside, or the elevator might open directly onto a floor engulfed in flames.',
  ),
  const QuizQuestion(
    id: 'q2_d5',
    disasterId: 'd5',
    question: 'What should you do if an indoor space begins to fill up rapidly with smoke?',
    options: [
      'Stand up tall and run fast.',
      'Crawl low to the ground to exit.',
      'Hide inside a closet.',
      'Open all windows aggressively and wait.'
    ],
    correctOptionIndex: 1,
    explanation: 'Smoke and toxic gases rise in a fire. The cleanest breathable air is located closer to the floor. Crawl quickly to your exit.',
  ),
  const QuizQuestion(
    id: 'q3_d5',
    disasterId: 'd5',
    question: 'If your clothing accidentally catches on fire, what protocol must you follow?',
    options: [
      'Run quickly to find water.',
      'Fan the flames with your hands.',
      'Stop, Drop, and Roll immediately.',
      'Take off the burning clothes while standing.'
    ],
    correctOptionIndex: 2,
    explanation: 'Stop, Drop, and Roll instantly smoothers the flames and deprives them of oxygen. Running feeds oxygen to the fire, making it spread faster.',
  ),
  const QuizQuestion(
    id: 'q4_d5',
    disasterId: 'd5',
    question: 'Before opening a closed door during a building fire, you should:',
    options: [
      'Kick it open quickly.',
      'Feel the doorknob and the door for heat using the back of your hand.',
      'Look through the keyhole for flames.',
      'Pour water on it.'
    ],
    correctOptionIndex: 1,
    explanation: 'If a door or its knob feels hot, fire is directly behind it on the other side. Opening it will cause an explosive backdraft of flames. Find another route.',
  ),

  // CHEMICAL & LAB ACCIDENTS (d6)
  const QuizQuestion(
    id: 'q1_d6',
    disasterId: 'd6',
    question: 'What is the immediate action recommended if an unknown chemical splashes into your eyes in a laboratory?',
    options: [
      'Rub your eyes rigorously.',
      'Apply neutralizing eye drops immediately.',
      'Flush eyes at the emergency eyewash station for at least 15 minutes.',
      'Cover eyes with a dry cloth and wait for a doctor.'
    ],
    correctOptionIndex: 2,
    explanation: 'Never rub! Flushing the eyes with continuous water for 15 minutes physically removes the chemical before it aggressively burns ocular tissue.',
  ),
  const QuizQuestion(
    id: 'q2_d6',
    disasterId: 'd6',
    question: 'What information does an MSDS (Material Safety Data Sheet) provide?',
    options: [
      'The price and supplier of the chemical.',
      'The hazards, safety precautions, and emergency procedures for a chemical.',
      'The grade of the student performing the experiment.',
      'The structural chemical formula only.'
    ],
    correctOptionIndex: 1,
    explanation: 'An MSDS is the absolute master guide containing handling procedures, flammability warnings, and the correct first-aid protocol for specific chemical exposures.',
  ),
  const QuizQuestion(
    id: 'q3_d6',
    disasterId: 'd6',
    question: 'In the event of a dangerous, highly toxic gas leak in the lab, what is the best protocol?',
    options: [
      'Investigate the source of the leak closely.',
      'Evacuate immediately, pulling the fire/emergency alarm on the way out.',
      'Hold your breath and try to finish your experiment quickly.',
      'Open an umbrella to shield yourself.'
    ],
    correctOptionIndex: 1,
    explanation: 'Toxic gases can incapacitate a person silently in seconds. Always evacuate the area immediately and alert others on your way out safely.',
  ),
  const QuizQuestion(
    id: 'q4_d6',
    disasterId: 'd6',
    question: 'If you casually spill a small amount of liquid chemical in the lab, you should:',
    options: [
      'Wipe it up quickly with your bare hands and a paper towel.',
      'Leave it alone to evaporate.',
      'Notify the lab instructor/officer to verify the correct safe cleanup procedure.',
      'Pour water on it to hide it.'
    ],
    correctOptionIndex: 2,
    explanation: 'Some chemicals react violently with water or are highly corrosive to bare skin. Always notify the instructor for proper neutralization and cleanup instructions.',
  ),
];
