# README #



### What is this repository for? ###

* Quick summary


* Version



### Set up ###

### Mock api calls ###


// ZEME
// http://www.windguru.cz/int/ajax/wg_ajax_json_select.php?q=zeme&id_georegion=5&exist_spots=1&id_model=0
// {"count":11,"zeme":[["32","Argentina"],["68","Bolivia"],["76","Brazil"],["170","Colombia"],["218","Ecuador"],["254","French Guiana"],["152","Chile"],["600","Paraguay"],["604","Peru"],["858","Uruguay"],["862","Venezuela"]]}

// REGIONS
// http://www.windguru.cz/int/ajax/wg_ajax_json_select.php?q=regions&id_zeme=32&id_georegion=5
// {"count":0}

// http://www.windguru.cz/int/ajax/wg_ajax_json_select.php?q=spots&id_zeme=32&id_region=0&id_georegion=5&cats=1_2_6_4_3_5_10_7_8_9_11&id_cuser=1031706&id_model=0&special=&opt=
// {"count":228,"spots":[["546356","Agrot\u00e9cnico 4 - San Pedro, Guasayan - Sgo del Estero, MeteoStar",-27.95667,-65.15788],["584762","Agroveterinaria El Bagual, Gobernador Gregores, Santa Cruz, Meteostar",-48.75137,-70.24375],["576413","AleIguera JNF, Juan N. Fernandez, Buenos Aires, MeteoStar",-38.00498,-59.26553],["558459","Aramis Group, Villa Angela, Chaco, Meteostar",-27.56137,-60.73306],["513573","Arroyito2, Cordoba, MeteoStar",-31.39704,-63.05467],["598910","ASRC, Arroyo Seco, Santa Fe, Meteostar",-33.14231,-60.48693],["546355","AWS Bella Vista, Buenos Aires, MeteoStar",-34.56462,-58.67306],["378049","Bahia de los Lobos, Laguna de Lobos",-35.28782,-59.136],["601556","Bah\u00eda de los Moros, Lober\u00eda,  Buenos Aires,, Meteostar",-38.52385,-58.47655],["209153","Bahia Serena",-41.1,-71.43],["513574","Balnearia, Cordoba, MeteoStar",-31.01289,-62.66543],["535479","Balneario El Condor Viedma, Rio Negro, MeteoStar",-40.92869,-64.39224],["507803","Baradero, Buenos Aires, MeteoStar",-33.82011,-59.49318],["64141","Bariloche",-41.1281,-71.34803],["209155","Bariloche Classic",-41.13,-71.31],["549917","Barrio Santa Clara - Tigre, Buenos Aires, MeteoStar",-34.39437,-58.7102],["568996","Belen15, Mor\u00f3n, Meteostar",-34.66007,-58.63045],["229241","Brazo Machete Nahuel Huapi",-40.81321,-71.67446],["261","Buenos Aires",-34.58,-58.4],["570933","Buxtehude, Villa General Belgrano, Meteostar",-31.96144,-64.55587],["535478","Campo Pressuttari Hernando, Cordoba, MeteoStar",-32.59362,-63.75193],["515853","Ca\u00f1ada de Gomez",-32.81361,-61.3675],["591701","Canal Local La Carlota, Cordoba, Meteostar",-33.4179,-63.298],["123610"," Caril\u00f3 - Hemingway",-37.16384,-56.88951],["513582","Carlos Casares, Buenos Aires, MeteoStar",-35.63141,-61.36124],["123606","Carlos Paz - San Roque",-31.38002,-64.4676],["507801","Carmen de Areco, Buenos Aires, MeteoStar",-34.27251,-59.95029],["604027","CASBAS CLIMA, Casbas, Buenos Aires, Meteostar",-36.75628,-62.49831],["513566","Castelli, Buenos Aires, MeteoStar",-36.08786,-57.81126],["558049","Central Pueblo Esther, Santa Fe, MeteoStar",-33.06741,-60.58089],["229239","Cerro Victoria",-34.77694,-68.4575],["8165","Claromeco",-38.82,-60.03],["589408","Clima de Chascom\u00fas, Meteostar",-35.55415,-58.01934],["585583","Club Universitario de Buenos Aires - Sede Nu\u00f1ez, CUBA - sede nu\u00f1ez",-34.53851,-58.45053],["513572","Colonia San Bartolome, Arroyito, Cordoba, MeteoStar",-31.41427,-63.05052],["562809","Comodoro Rivadavia",-45.85935,-67.47326],["513577","Cordoba Capital, Cordoba, MeteoStar",-31.4225,-64.20365],["513578","Cordoba2, Cordoba, MeteoStar",-31.35838,-64.26915],["281153","Coronel Suarez ",-37.45197,-61.94402],["513585","Coronel Suarez, Buenos Aires, MeteoStar",-37.3816,-61.50049],["525998","Corpen Aike - Pto. Sta.Cruz, Santa Cruz, MeteoStar",-50.02192,-68.51888],["439923","Corrientes",-27.51801,-58.84277],["275765","Costa Esmeralda ",-37.01806,-56.77917],["230394","Cuero de Zorro",-35.7805,-62.91081],["128492","Cuesta del Viento",-30.18806,-69.07417],["523968","Cuesta del viento Ghmcontenidos, San Juan, MeteoStar",-30.19448,-69.10153],["209182","Del Balc\u00f3n",-38.09,-57.54],["558100","Delta Marina Guarder\u00eda N\u00e1utica, Villa La \u00d1ata, Tigre",-34.3669,-58.66668],["535480","dfb Cipolletti, Rio Negro, MeteoStar",-38.92559,-67.97927],["128551","Dique de Ull\u00fam - San Juan",-31.46389,-68.65778],["120879","Dique Paso Piedras",-38.40962,-61.75158],["209180","Diva",-38.08,-57.54],["589217","EDURIOS, Del Viso,, Meteostar",-34.44736,-58.79807],["476668","El Calafate",-50.285,-72.287],["598809","El Carril, Salta, Meteostar",-24.43571,-65.24357],["128932","El Carrizal - Mendoza",-33.32944,-68.72778],["119155","El Condor",-41.04333,-62.80556],["590822","El Dichoso, Colonia Ben\u00edtez, Chaco, Meteostar",-27.3581,-58.99967],["518941","El Hoyo Chubut, MeteoStar",-42.12003,-71.43407],["597296","El Choike , Bariloche, Meteostar",-41.11384,-71.22896],["209184","El Mirador 10",-38.1,-57.55],["171334","El Molino",-34.47311,-58.49074],["582949","EMA ROSARIO SUR (TIRO SUIZO), Meteostar",-32.99471,-60.65113],["181974","Embalse Rio Tercero",-32.19915,-64.48837],["523970","Estaci\u00f3n Bioder Parana, Entre R\u00edos, MeteoStar",-31.82709,-60.24138],["533502","Estaci\u00f3n Costera Municipal Villa Gesell, Buenos Aires, MeteoStar",-37.27926,-56.98235],["523971","Estaci\u00f3n de Servicio Ruano, Peyrano Santa Fe, MeteoStar",-33.53579,-60.79708],["546354","Estaci\u00f3n Huinca Renanco, Cordoba, MeteoStar",-34.83634,-64.37211],["542930","Estaci\u00f3n Las Isletillas Hernando, Cordoba, MeteoStar",-32.51047,-63.9888],["525997","Estaci\u00f3n Mauro - Hernando, Cordoba, MeteoStar",-32.46368,-63.97626],["558447","Estaci\u00f3n Meteorol\u00f3gica Aer\u00f3dromo Rafaela, Meteostar",-31.27751,-61.50974],["561372","E.T. Puerto Moreno, Bariloche, Meteostar",-41.11158,-71.42045],["562460","Facultad Agronom\u00eda-Agrometeorolog\u00eda, Azul, Buenos Aires, Meteostar",-36.76623,-59.88185],["549918","Ferrari - Claromeco, Buenos Aires, MeteoStar",-38.85949,-60.07149],["209165","Fincas del Lago",-30.16,-69.1],["371057","Formosa",-26.19278,-58.15222],["513581","Gancedo, Chaco, MeteoStar",-27.32361,-61.75856],["516415","General Arenales",-34.30261,-61.30345],["507798","General Cabrera, C\u00f3rdoba, MeteoStar",-32.80113,-63.85693],["513575","General Levalle, Cordoba, MeteoStar",-34.16029,-64.0048],["91085","Hinojo Grande",-35.94131,-62.56523],["209159","Huapi Brazo Huemul",-40.94,-71.37],["507808","Chajar\u00ed, Corrientes, MeteoStar",-30.6564,-58.07664],["567520","Chancani, Cordoba, Meteostar",-31.41637,-65.44813],["5687","Chascomus",-35.6,-58.02],["513364","Chascomus, Aer\u00f3dromo Skydivecenter",-35.53949,-58.05193],["90107","Chasico",-38.62944,-63.07306],["275768","Chivilcoy ",-34.88333,-60.08333],["501479","Chivilcoy, MeteoStar",-34.88424,-60.03119],["565377","ibuenosa217, Boulogne, Buenos Aires, Meteostar",-34.50789,-58.55854],["596478","Instituto Agropecuario de Monte, Meteostar",-35.42198,-58.818],["549916","INTA - San A. de Areco, Buenos Aires, MeteoStar",-34.2043,-59.54554],["74124","Isla Escondida",-43.70278,-65.26944],["122063","Junin",-34.58,-60.94],["9441","La Balandra",-34.92,-57.73],["507812","Laboulaye, C\u00f3rdoba, MeteoStar",-34.16442,-64.06993],["493214","La Calera, Cordoba, Estacion Voler Parapente",-31.3317,-64.3423],["567486","La Candelaria, Salta, Meteostar",-26.12693,-65.0485],["590967","\"La Esmeralda\", Pueblo Bellocq (Estaci\u00f3n Las Garzas), Hasenkamp, Meteostar",-31.39384,-59.71096],["209162","Lago Gutierrez",-41.17,-71.39],["245924","Lago Los Molinos",-31.82244,-64.53455],["128550","Lago Moquehue - Neuqu\u00e9n",-38.90306,-71.27361],["209161","Lago Moreno",-41.1,-71.48],["80503","Lago Puelo",-42.12,-71.64],["417132","Lago Salto Grande",-31.24415,-57.92966],["329633","La Gostosa",-31.54994,-60.62472],["366064","Laguna Brava",-37.87,-57.9833],["91086","Laguna Cochico",-36.90279,-62.30092],["542939","Laguna del Burro",-35.68854,-57.95189],["212897","Laguna del Pescado",-32.7,-60.09],["209170","Laguna Mar Chiquita",-37.64,-57.4],["246723","Laguna Mar Chiquita (C\u00f3rdoba)",-30.66667,-62.83333],["298837","Laguna Melincue ",-33.68357,-61.46488],["209166","La Isleta",-30.18,-69.09],["513571","La Pega, Mendoza, MeteoStar",-32.81046,-68.67218],["209174","La Popular",-38,-57.54],["546357","La Primavera, Rio Cuarto - Cordoba, MeteoStar",-32.40207,-63.987],["558152","La Providencia bajo, Mar del Plata, Buenos Aires, Meteostar",-37.89159,-57.96222],["209183","La Reserva",-38.1,-57.55],["105315","La Set\u00fabal (Santa Fe)",-31.6228,-60.6756],["286049","Las Grutas Rio Negro ",-40.75833,-64.93667],["513583","Las Toscas, Santa Fe, MeteoStar",-28.35241,-59.25957],["206942","La Terraza",-34.827,-57.8741],["513569","Leones, Cordoba, MeteoStar",-32.65879,-62.29741],["568993","Locos Por El Viento, Rosario, Meteostar",-32.87504,-60.69565],["572598","Lomas de Zamora, Buenos Aires, Mschvartz",-34.76493,-58.40813],["209185","Los Acantilados",-38.11,-57.59],["209169","Los Horcones",-37.06,-57],["533498","Los Petisos - Coronel Pringles, Buenos Aires, MeteoStar",-38.51116,-61.75552],["513568","Lujan, Buenos Aires, MeteoStar",-34.56799,-59.1179],["533500","LU9ACA Capital Federal, Buenos Aires, MeteoStar",-34.58207,-58.45341],["209168","Mar Azul",-37.34,-57.02],["123608","Mar de Aj\u00f3",-36.72189,-56.67237],["209172","Mar de Cobo",-37.77,-57.44],["3640","Mar del Plata",-38,-57.55],["507806","Mar del Plata, FreeWaves, MeteoStar",-38.0322,-57.5317],["209171","Mar Chiquita",-37.74,-57.41],["533499","Mar Chiquita Buenos Aires, FreeWaves, MeteoStar",-37.74414,-57.42422],["533501","Mariano Acosta, Buenos Aires, MeteoStar",-34.72517,-58.79286],["513579","Mechita, Buenos Aires, MeteoStar",-35.06524,-60.39789],["546358","Meteo Col\u00f3n, Col\u00f3n - Buenos Aires, MeteoStar",-33.89617,-61.09717],["542929","Meteo Chivilcoy, Buenos Aires, MeteoStar",-34.91658,-60.01442],["558146","Meteo Salto, Buenos Aires,, Meteostar",-34.31029,-60.22724],["597652","Meteosanpedro, San Pedro, Buenos Aires, Meteostar",-33.67458,-59.666],["562355","Meteo 9 de Julio, Meteostar",-35.42478,-60.89376],["560715","Mina Clavero, Cordoba, Meteostar",-31.73058,-65.01439],["580778","Mirador de los condores APC, Merlo, San Luis, Meteostar",-32.45256,-64.93363],["209186","Miramar",-38.24,-57.77],["3639","Monte Hermoso",-38.98,-61.25],["130660","\u00d1andubaysal - Gualeguaychu",-33.07,-58.38],["8170","Necochea",-38.57,-58.71],["507813","Necochea, Buenos Aires, MeteoStar",-38.42158,-58.37781],["535481","Ni\u00f1a Paula San Alberto, Cordoba, MeteoStar",-31.73843,-64.92063],["584271","ObsMeteoCODE, Santa Fe, Meteostar",-31.63366,-60.68079],["126664","Or\u00e1n (Salta)",-23,-64.5],["366058","Pampa Balloons",-35.00668,-58.71809],["356415","Paran\u00e1",-31.76753,-60.50903],["596476","Paso Cordoba, Rio Negro, Meteostar",-39.1356,-67.5961],["88345","Per\u00fa Beach",-34.4706,-58.49029],["8158","Pinamar",-37.12,-56.83],["576957","Pipanaco, Catamarca, Argentina, Meteostar",-27.98298,-66.20037],["523969","Planta Diaema - Comodoro Rivadavia, Chubut, MeteoStar",-45.41034,-67.4148],["533503","Planta Ruta 193 Solis, Buenos Aires, MeteoStar",-34.28992,-59.30818],["209154","Playa Bonita",-41.12,-71.39],["209175","Playa Grande",-38.02,-57.53],["209181","Playa Horizonte",-38.09,-57.54],["209164","Playa Lamaral",-30.17,-69.1],["523972","Porta1, Cordoba, MeteoStar",-34.47058,-64.19208],["128552","Potrerillos - Mendoza",-32.95806,-69.18167],["85123","Potrero de Garay",-31.806,-64.537],["573737","Presidente Roca, METEOBRIDGE WH3104",-31.20895,-61.6144],["594378","Protecci\u00f3n Civil VLA , Villa la Angostura,Neuquen, Meteostar",-40.7666,-71.64722],["558148","Puente Viejo Bajo, Mar del Plata, Buenos Aires, Meteostar",-37.9585,-57.74274],["209176","Puerto",-38.03,-57.53],["8161","Puerto Belgrano",-38.88,-62.1],["209163","Puerto de Palos",-30.17,-69.09],["286059","Puerto Deseado ",-47.75,-65.91667],["329647","Puerto Ingeniero White",-38.8,-62.28333],["38834","Puerto Madryn",-42.73,-65.02],["107895","Puerto Tablas",-34.47111,-58.48778],["206943","Puerto Velas",-34.8139,-57.975],["603153","PULMARI, Ezeiza, Buenos Aires, Meteostar",-34.81772,-58.59562],["593669","Punta Lara EL MIRADOR, FreeWaves",-34.81994,-57.9672],["593671","Punta Lara EL MIRADOR, FreeWaves",-34.81992,-57.96712],["75752","Punta Lara - Puerto Velas",-34.812,-57.973],["209177","Punta Mogotes",-38.07,-57.54],["209167","Punta Rasa",-36.29,-56.77],["53445","Punta Rasa - San Clemente",-36.29611,-56.775],["114368","Quilmes",-34.70779,-58.22668],["183130","Rada Tilly",-45.98169,-67.54394],["588440","Radio Libertad, Rosario, Santa Fe, Meteostar",-32.94979,-60.63669],["209160","Ragintuco",-40.83,-71.53],["513570","Rauch, Buenos Aires, MeteoStar",-36.7742,-59.08998],["513580","Rio Gallegos, Santa Cruz, MeteoStar",-51.44897,-70.19528],["209158","Rivermouth",-41.05,-71.15],["518939","Rojas Buenos, Aires, MeteoStar",-34.20495,-60.72641],["507811","Roldan, Santa Fe, MeteoStar",-32.92702,-60.87365],["63632","Rosario",-32.93,-60.63],["507797","Rosario, Santa Fe, MeteoStar",-32.90602,-60.687],["507799","Saladillo, Buenos Aires, MeteoStar",-35.84671,-60.35823],["507805","Saladillo, Buenos Aires, MeteoStar",-35.64511,-59.77551],["501396","San Antonio de Areco, MeteoStar",-34.24458,-59.47615],["562455","San Carlos Minas, Cordoba, Meteostar",-31.18153,-65.10182],["375355","San Clemente del Tuyu",-36.36,-56.71],["560694","San Francisco, Mar del Plata, Buenos Aires, Meteostar",-37.96416,-57.69488],["507809","San Guillermo, San Juan, MeteoStar",-29.06042,-69.33428],["518940","San Isidro, Buenos Aires, FreeWaves, MeteoStar",-34.4727,-58.49028],["358498","San Martin de Los Andes ",-40.16182,-71.36016],["507804","San Miguel, Buenos Aires, MeteoStar",-34.54039,-58.71268],["229243","San Miguel del Monte (Laguna)",-35.459,-58.804],["85131","San Pedro (Buenos Aires)",-33.67278,-59.65694],["507807","San Rafael, Mendoza, MeteoStar",-34.75852,-68.0713],["209179","San Remo",-38.08,-57.53],["209173","Santa Clara del Mar",-37.83,-57.49],["267479","Santa Rosa",-36.623,-64.315],["558141","Sec. de Ambiente  Munic. de Gral. Viamonte, Meteostar",-35.00189,-61.01198],["507800","Sierras Bayas, Olavarria, Buenos Aires, MeteoStar",-36.93294,-60.16442],["533497","TL-82 - Tranque Lauquen, Buenos Aires, MeteoStar",-35.96953,-62.73159],["507810","Tornquist, Buenos Aires, MeteoStar",-38.05705,-62.1362],["275754","Traslasierra - Loma Bola ",-32.228,-65.047],["513576","Treinta de Agosto, Buenos Aires, MeteoStar",-36.20248,-62.56687],["209156","Varadero Beach",-41.12,-71.26],["507796","Villa Ca\u00f1as, Santa Fe, MeteoStar",-34.09489,-61.6288],["513586","Villa Carlos Paz, Cordoba, MeteoStar",-31.47502,-64.5273],["133105","Villa Gesell",-37.245,-56.95472],["516418","Villa Regina Rio Negro, MeteoStar",-39.0833,-67.21646],["209178","Waikiki",-38.08,-57.53],["209157","West",-41.1,-71.19]]}

// http://www.windguru.cz/js/wg_user_colors_json.php
/*
 var WgColors = {};
 WgColors['wind'] = new WgPalette([
	[0, 255, 255, 255],
	[5, 255, 255, 255],
	[8.9, 103, 247, 241],
	[13.5, 0, 255, 0],
	[18.8, 255, 240, 0],
	[24.7, 255, 50, 44],
	[31.7, 255, 10, 200],
	[38, 255, 0, 255],
	[45, 150, 50, 255],
	[60, 60, 60, 255],
	[70, 0, 0, 255]
 ]);
 WgColors['temp'] = new WgPalette([
	[-25, 80, 255, 220],
	[-15, 171, 190, 255],
	[0, 255, 255, 255],
	[10, 255, 255, 100],
	[20, 255, 170, 0],
	[30, 255, 50, 50],
	[35, 255, 0, 110],
	[40, 255, 0, 160],
	[50, 255, 80, 220]
 ]);
 WgColors['cloud'] = new WgPalette([
	[0, 255, 255, 255],
	[100, 120, 120, 120]
 ]);
 WgColors['precip'] = new WgPalette([
	[0, 255, 255, 255],
	[9, 115, 115, 255],
	[30, 115, 115, 255]
 ]);
 WgColors['precip1'] = new WgPalette([
	[0, 255, 255, 255],
	[3, 115, 115, 255],
	[10, 115, 115, 255]
 ]);
 WgColors['press'] = new WgPalette([
	[900, 80, 255, 220],
	[1000, 255, 255, 255],
	[1070, 115, 115, 255]
 ]);
 WgColors['rh'] = new WgPalette([
	[0, 171, 190, 255],
	[50, 255, 255, 255],
	[100, 255, 255, 0]
 ]);
 WgColors['htsgw'] = new WgPalette([
	[0, 255, 255, 255],
	[0.3, 255, 255, 255],
	[4, 120, 120, 255],
	[10, 255, 80, 100],
	[15, 255, 200, 100]
 ]);
 WgColors['perpw'] = new WgPalette([
	[0, 255, 255, 255],
	[10, 255, 255, 255],
	[20, 252, 81, 81]
 ]);
 */


// https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=user&username=southfox&password=*******
// {"id_user":1031706,"username":"southfox","id_country":"32","wind_units":"knots","temp_units":"c","wave_units":"m","pro":1,"no_ads":1,"view_hours_from":4,"view_hours_to":22,"temp_limit":10,"wind_rating_limits":[11,15,19],"colors":{"wind":[[0,255,255,255],[5,255,255,255],[8.9,103,247,241],[13.5,0,255,0],[18.8,255,240,0],[24.7,255,50,44],[31.7,255,10,200],[38,255,0,255],[45,150,50,255],[60,60,60,255],[70,0,0,255]],"temp":[[-25,80,255,220],[-15,171,190,255],[0,255,255,255],[10,255,255,100],[20,255,170,0],[30,255,50,50],[35,255,0,110],[40,255,0,160],[50,255,80,220]],"cloud":[[0,255,255,255],[100,120,120,120]],"precip":[[0,255,255,255],[9,115,115,255],[30,115,115,255]],"precip1":[[0,255,255,255],[3,115,115,255],[10,115,115,255]],"press":[[900,80,255,220],[1000,255,255,255],[1070,115,115,255]],"rh":[[0,171,190,255],[50,255,255,255],[100,255,255,0]],"htsgw":[[0,255,255,255],[0.3,255,255,255],[4,120,120,255],[10,255,80,100],[15,255,200,100]],"perpw":[[0,255,255,255],[10,255,255,255],[20,252,81,81]]}}


// https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=spots&username=southfox&password=*******



