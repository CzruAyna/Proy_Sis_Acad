"""Project the selected FNI features from an external OSM XML export."""

import argparse
import json
from pathlib import Path
import xml.etree.ElementTree as ET


SOUTH, WEST = -17.99427, -67.13950
NORTH_FACTOR, EAST_FACTOR = 111195, 105760
UNITS = 8
SIZE = (7040, 3904)

# Matches by position and the annotated plan. OSM names only some of these.
BUILDINGS = {
    "metalurgia": 948045991, "metalurgia2": 948045915, "comedor": 948045996,
    "matematicas": 657668270, "geologia": 657668317, "admin_geo": 948046005,
    "posta": 948045936, "industrial": 948045997, "sis_d": 657668320,
    "sis_a": 657668318, "sis_b": 657668319, "admin_sis": 548885224,
    "decanato": 948045973, "electrica_aulas": 630390254, "asfaltos": 948045995,
    "sanitaria": 948045986, "hidraulica": 948045987, "resistencia": 948045988,
    "diseno": 948045983, "topografia": 948045984, "quirquincho_quimica": 548885228,
    "min_sc": 948045914, "minas": 948045975, "fisica": 948045967,
    "quirquincho_fisica": 548885219, "quimica_lab": 657668271,
    "quimica_aulas": 657668275, "mecanica": 948045978, "biblioteca": 948045982,
    "fis_mat": 630456837, "basicas": 587273320, "civil": 657668321,
    "proc_quimicos": 948045959, "internado": 948045965, "ppu": 948045992,
    "coliseo": 948045917,
}
COURTS = {
    "FÚTBOL SINTÉTICO": 277946021, "VOLEIBOL": 948045989,
    "POLIF. INDUSTRIAL": 657668269, "POLIF. QUÍMICA": 657668268,
    "POLIF. MINAS": 657668265, "POLIF. CIVIL": 630456836,
}
SERVICE = [422071976, 422071977, 422071979, 422071980, 96620895, 96620810,
           96620839, 96620849, 96620807, 549011266]


def project(node):
    north = (float(node.attrib["lat"]) - SOUTH) * NORTH_FACTOR
    east = (float(node.attrib["lon"]) - WEST) * EAST_FACTOR
    return [round(north * UNITS), round(east * UNITS)]


def generate(source):
    root = ET.parse(source).getroot()
    nodes = {int(node.attrib["id"]): project(node) for node in root.findall("node")}
    ways = {int(way.attrib["id"]): way for way in root.findall("way")}

    def feature(osm_id, polygon=False):
        way = ways[osm_id]
        tags = {tag.attrib["k"]: tag.attrib["v"] for tag in way.findall("tag")}
        points = []
        for ref in way.findall("nd"):
            point = nodes[int(ref.attrib["ref"])]
            if not points or point != points[-1]:
                points.append(point)
        if polygon and points[0] == points[-1]:
            points.pop()
        return {"way": osm_id, "points": points, "name": tags.get("name", "")}

    def in_crop(points):
        return all(0 <= x <= SIZE[0] and 0 <= y <= SIZE[1] for x, y in points)

    gardens, walkways = [], []
    for osm_id, way in sorted(ways.items()):
        tags = {tag.attrib["k"]: tag.attrib["v"] for tag in way.findall("tag")}
        garden = tags.get("leisure") in {"park", "garden"} and 473000000 <= osm_id <= 588000000
        walkway = tags.get("highway") in {"footway", "path", "steps"} and 473000000 <= osm_id <= 588000000
        if not (garden or walkway):
            continue
        row = feature(osm_id, garden)
        if len(row["points"]) >= (3 if garden else 2) and in_crop(row["points"]):
            (gardens if garden else walkways).append(row)

    gate = feature(96620810)["points"][2]
    return {
        "attribution": "© OpenStreetMap contributors",
        "license": "https://opendatacommons.org/licenses/odbl/1-0/",
        "source": "https://www.openstreetmap.org/#map=17/-17.990505/-67.139089",
        "bounds_units": SIZE,
        "projection": {"south": SOUTH, "west": WEST, "north_m_per_deg": NORTH_FACTOR,
                       "east_m_per_deg": EAST_FACTOR, "units_per_m": UNITS},
        "gate": gate,
        "chivato": {"node": 4682413170, "point": nodes[4682413170]},
        "buildings": {key: feature(osm_id, True) for key, osm_id in BUILDINGS.items()},
        "courts": {key: feature(osm_id, True) for key, osm_id in COURTS.items()},
        "roads": [feature(osm_id) for osm_id in SERVICE],
        "walkways": walkways,
        "gardens": gardens,
        "parking": [feature(422071978, True), feature(658187649, True)],
        "fountains": [feature(473486560, True), feature(484648944, True)],
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    result = generate(args.source)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, separators=(",", ":")) + "\n",
                           encoding="utf-8")
