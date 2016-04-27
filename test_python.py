#! /usr/bin/env python3

from python_exports import haxpression_PythonExports as Expr
import json

#print(Expr.parseEvaluate('a + b', { 'a': 1, 'b': 2 }))
#print(Expr.toDict('a + b'))
mappings = {
    "ratios_ebitda_margin": ["asn_ebitda / asn_sales"],
    "ratios_ni_margin": ["asn_ni / asn_sales"],
    "asn_ebitda": ["fs_ebitda"],
    "asn_ni": ["fs_ni"],
    "asn_sales": ["fs_sales"],
    "fs_ebitda": ["iq_ebitda"],
    "fs_ni": ["iq_ni"],
    "fs_sales": ["iq_sales"]
}

fields = ["ratios_ebitda_margin", "ratios_ni_margin"]

info = Expr.getEvaluationInfo(mappings, fields)

print(json.dumps(info, indent=2));
