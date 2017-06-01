#! /usr/bin/env python3

from haxpression import haxpression_python_PythonExports as Expr
import json

Expr.loggingEnabled = False

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

def printEvaluationInfo(fields):
    print('--------------------------------------------------------------------------------')
    print('requesting fields: ', fields)
    print('--------------------------------------------------------------------------------')
    info = Expr.getEvaluationInfo(mappings, fields)
    print(json.dumps(info, indent=2))

printEvaluationInfo(["ratios_ebitda_margin", "ratios_ni_margin"])
printEvaluationInfo(["ratios_ebitda_margin"])
printEvaluationInfo(["ratios_ni_margin"])
printEvaluationInfo(["asn_sales", "asn_ni"])
printEvaluationInfo(["asn_sales"])
printEvaluationInfo(["fs_sales", "fs_ni"])
printEvaluationInfo(["fs_sales"])
printEvaluationInfo(["iq_sales", "iq_ni"])
printEvaluationInfo(["iq_sales"])
