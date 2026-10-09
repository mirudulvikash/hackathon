import 'package:flutter/material.dart';
import '../../models/disaster_model.dart';

/// Presentation metadata (display titles, module counts, durations, subtitles)
/// keyed by disaster id, used by the redesigned Learn & Dashboard screens.
const Map<String, Map<String, Object?>> moduleDetails = {
  'd1': {
    'title': 'Flood Safety Protocol',
    'modules': 4,
    'minutes': 25,
    'subtitle': 'Rising Waters & Rescue',
  },
  'd2': {
    'title': 'Earthquake Drills',
    'modules': 3,
    'minutes': 18,
    'subtitle': 'Drop, Cover & Hold On',
  },
  'd3': {
    'title': 'Cyclone Readiness',
    'modules': 3,
    'minutes': 20,
    'subtitle': 'Coastal Storm Precautions',
  },
  'd4': {
    'title': 'Landslide Early Detection',
    'modules': 2,
    'minutes': 15,
    'subtitle': 'Hillside Slope Warning',
  },
  'd5': {
    'title': 'Campus Fire & Electrical Safety',
    'modules': 4,
    'minutes': 30,
    'subtitle': 'Extinguishers & Egress',
  },
  'd6': {
    'title': 'Chemical & Lab Safety',
    'modules': 3,
    'minutes': 22,
    'subtitle': 'Lab Spills & PPE Gear',
  },
};

String moduleTitle(DisasterModel d) =>
    moduleDetails[d.id]?['title'] as String? ?? d.name;
int moduleCount(DisasterModel d) =>
    moduleDetails[d.id]?['modules'] as int? ?? 4;
int moduleMinutes(DisasterModel d) =>
    moduleDetails[d.id]?['minutes'] as int? ?? 20;
String moduleSubtitle(DisasterModel d) =>
    moduleDetails[d.id]?['subtitle'] as String? ?? d.shortDescription;

final List<DisasterModel> mockDisasters = [
  const DisasterModel(
    id: 'd1',
    name: 'Flood',
    category: 'Natural',
    iconName: Icons.water,
    imagePath: 'assets/images/flood.png',
    shortDescription: 'Overflow of water onto normally dry land.',
    whatIsIt: 'A flood is an overflow of water that submerges land that is usually dry.',
    causes: [
      'Heavy or prolonged rainfall.',
      'Cyclones and storm surges.',
      'Deforestation and poor drainage systems.'
    ],
    warningSigns: [
      'Continuous heavy rain alerts from authorities.',
      'Rapid rise in nearby river or lake water levels.',
    ],
    beforeActions: [
      'Know your local flood risk and elevation.',
      'Prepare an emergency kit with food, water, and meds.',
      'Move valuables to higher floors.'
    ],
    duringActions: [
      'Turn off utilities at main switches if instructed.',
      'Move to higher ground immediately.',
      'Do not walk or drive through moving water.'
    ],
    afterActions: [
      'Wait for official all-clear signals before returning.',
      'Avoid standing water as it may be electrically charged.',
      'Clean and disinfect everything that got wet.'
    ],
    safetyPrecautions: [
      'Keep important documents in waterproof containers.',
      'Listen to local weather channels regularly.'
    ],
    mistakesToAvoid: [
      'Driving through flooded roads (Turn around, don\'t drown).',
      'Drinking tap water before it is declared safe.'
    ],
    relevantLocations: ['Coimbatore', 'Chennai', 'Nilgiris', 'Madurai', 'Tiruchirappalli', 'Kanyakumari'],
  ),
  const DisasterModel(
    id: 'd2',
    name: 'Earthquake',
    category: 'Natural',
    iconName: Icons.broken_image,
    imagePath: 'assets/images/earthquake.png',
    shortDescription: 'Sudden shaking of the ground caused by seismic waves.',
    whatIsIt: 'An earthquake is the shaking of the surface of the Earth resulting from a sudden release of energy in the Earth\'s lithosphere.',
    causes: [
      'Tectonic plate movements.',
      'Volcanic eruptions.',
      'Human-induced elements like deep well injection.'
    ],
    warningSigns: [
      'Minor tremors or foreshocks.',
      'Restless strange animal behavior (sometimes reported).',
    ],
    beforeActions: [
      'Identify safe places in each room (under heavy furniture).',
      'Fasten heavy items securely to walls.',
      'Practice "Drop, Cover, and Hold On".'
    ],
    duringActions: [
      'Drop to your hands and knees.',
      'Cover your head and neck (under a sturdy desk/table).',
      'Hold on to your shelter until shaking stops.',
      'If outside, stay away from buildings, streetlights, and wires.'
    ],
    afterActions: [
      'Expect aftershocks.',
      'Check for injuries and apply first aid.',
      'Exit the building safely if it is damaged.'
    ],
    safetyPrecautions: [
      'Keep emergency kits accessible.',
      'Memorize emergency contact numbers.'
    ],
    mistakesToAvoid: [
      'Running outside while the building is shaking.',
      'Standing in a doorway (no safer than under a desk).'
    ],
    relevantLocations: ['Coimbatore', 'Chennai', 'Salem'],
  ),
  const DisasterModel(
    id: 'd3',
    name: 'Cyclone',
    category: 'Natural',
    iconName: Icons.storm,
    imagePath: 'assets/images/cyclone.png',
    shortDescription: 'Violent storms with intense circular winds.',
    whatIsIt: 'A cyclone is a large scale air mass that rotates around a strong center of low atmospheric pressure, accompanied by destructive winds and heavy rain.',
    causes: [
      'Warm ocean waters.',
      'Atmospheric instability.'
    ],
    warningSigns: [
      'Official IMD cyclone alerts.',
      'Increasingly strong, gusty winds.',
      'Darkening skies and sudden heavy rainfall.'
    ],
    beforeActions: [
      'Board up windows with plywood.',
      'Trim trees and branches near your home.',
      'Evacuate immediately if ordered by authorities.'
    ],
    duringActions: [
      'Stay indoors and away from windows.',
      'Turn off main electricity if water enters.',
      'Do not be fooled by the "eye" of the storm.'
    ],
    afterActions: [
      'Beware of fallen power lines.',
      'Do not enter severely damaged buildings.',
      'Check in with family using SMS rather than calling.'
    ],
    safetyPrecautions: [
      'Have a battery-operated radio handy.',
      'Stock up on non-perishable food.'
    ],
    mistakesToAvoid: [
      'Going outside during the calm eye of the cyclone.',
      'Using candles in extreme winds (fire hazard).'
    ],
    relevantLocations: ['Chennai', 'Kanyakumari', 'Madurai'],
  ),
  const DisasterModel(
    id: 'd4',
    name: 'Landslide',
    category: 'Natural',
    iconName: Icons.terrain,
    imagePath: 'assets/images/landslide.png',
    shortDescription: 'Movement of rock, earth, or debris down a sloped section of land.',
    whatIsIt: 'A landslide is the downward sliding of a relatively dry mass of earth and rock.',
    causes: [
      'Heavy rainfall saturating the soil.',
      'Earthquakes or volcanic eruptions.',
      'Deforestation on steep slopes.'
    ],
    warningSigns: [
      'Changes in landscape like leaning trees or poles.',
      'Sudden appearance of springs or saturated ground.',
      'Cracks in house foundations or streets.'
    ],
    beforeActions: [
      'Understand the local landslide risk.',
      'Plant deep-rooted vegetation on slopes.',
      'Prepare to evacuate quickly.'
    ],
    duringActions: [
      'Move out of the path of the landslide or debris flow.',
      'If escape is not possible, curl into a tight ball and protect your head.',
    ],
    afterActions: [
      'Stay away from the slide area.',
      'Listen to local radio or TV for emergency information.',
      'Report broken utility lines to appropriate authorities.'
    ],
    safetyPrecautions: [
      'Watch for flooded roads and mud.',
      'Consult professionals before building on steep slopes.'
    ],
    mistakesToAvoid: [
      'Ignoring evacuation orders.',
      'Returning home before authorities say it\'s safe.'
    ],
    relevantLocations: ['Nilgiris', 'Salem'],
  ),
  const DisasterModel(
    id: 'd5',
    name: 'Fire Accidents',
    category: 'Man-Made',
    iconName: Icons.local_fire_department,
    imagePath: 'assets/images/fire_safety.png',
    shortDescription: 'Uncontrolled fires in buildings, schools, or public spaces.',
    whatIsIt: 'A fire accident is an uncontrolled fire that can cause severe death, injury, and property damage.',
    causes: [
      'Faulty electrical wiring.',
      'Unattended cooking or heating appliances.',
      'Careless smoking or matches.'
    ],
    warningSigns: [
      'Smell of smoke or burning materials.',
      'Fire alarms sounding.',
      'Visible flames.'
    ],
    beforeActions: [
      'Install smoke alarms and test them monthly.',
      'Create and practice a fire escape plan.',
      'Keep fire extinguishers accessible.'
    ],
    duringActions: [
      'Get out quickly. Do not waste time saving property.',
      'If there is smoke, crawl low under it.',
      'If clothes catch fire: Stop, Drop, and Roll.'
    ],
    afterActions: [
      'Do not re-enter the building until the fire department says so.',
      'Check for burns and treat appropriately.',
      'Contact insurance providers.'
    ],
    safetyPrecautions: [
      'Never leave cooking unattended.',
      'Keep flammable items away from heat sources.'
    ],
    mistakesToAvoid: [
      'Using elevators during a fire evacuation.',
      'Opening doors that feel hot to the touch.'
    ],
    relevantLocations: ['Coimbatore', 'Chennai', 'Nilgiris', 'Madurai', 'Tiruchirappalli', 'Salem', 'Kanyakumari'],
  ),
  const DisasterModel(
    id: 'd6',
    name: 'Chemical & Lab Accidents',
    category: 'Man-Made',
    iconName: Icons.science,
    imagePath: 'assets/images/chemical_spill.png',
    shortDescription: 'Spills or exposure to hazardous chemicals in labs or industries.',
    whatIsIt: 'Accidental release or spill of toxic, corrosive, or flammable chemicals.',
    causes: [
      'Improper handling of chemicals.',
      'Lack of proper safety gear.',
      'Equipment failure or poor ventilation.'
    ],
    warningSigns: [
      'Strong, unusual chemical odors.',
      'Irritation to eyes, skin, or respiratory system.',
    ],
    beforeActions: [
      'Always read the Material Safety Data Sheet (MSDS).',
      'Wear appropriate PPE (goggles, gloves, lab coats).',
      'Know the location of eye wash stations and safety showers.'
    ],
    duringActions: [
      'Evacuate the immediate area and alert others.',
      'Use emergency showers or eye wash if exposed.',
      'Do not try to clean a major spill yourself.'
    ],
    afterActions: [
      'Seek medical attention for any exposure.',
      'Ventilate the area thoroughly.',
      'Report the incident to the safety officer.'
    ],
    safetyPrecautions: [
      'Label all containers clearly.',
      'Never mix chemicals unless instructed safely.'
    ],
    mistakesToAvoid: [
      'Running within the laboratory.',
      'Cleaning a chemical spill without proper training/gear.'
    ],
    relevantLocations: ['Coimbatore', 'Chennai', 'Tiruchirappalli', 'Madurai'],
  )
];
