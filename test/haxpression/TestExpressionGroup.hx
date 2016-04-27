package haxpression;

import utest.Assert;
using haxpression.utils.StringValueMaps;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;

class TestExpressionGroup {
  public function new() {
  }

  public function testGetVariables() {
    var group = new ExpressionGroup([
      "a" => "b + c",
      "b" => "d + e",
      "c" => "f",
      "x" => "y + z"
    ]);
    Assert.same(["a", "b", "c", "x"], group.getVariables(false));
    Assert.same(["a", "b", "c", "d", "e", "f", "x", "y", "z"], group.getVariables(true));

    Assert.same(["d", "e", "f", "y", "z"], group.getExternalVariables());
    Assert.same(["d", "e", "f"], group.getExternalVariables(["a"]));
    Assert.same(["y", "z"], group.getExternalVariables(["x"]));
    Assert.same(["y"], group.getExternalVariables(["y"]));

    Assert.same(["z", "y", "x", "f", "e", "d", "c", "b", "a"], group.getDependencySortedVariables());
    Assert.same(["f", "e", "d", "c", "b", "a"], group.getDependencySortedVariables(["a"]));
    Assert.same(["e", "d", "b"], group.getDependencySortedVariables(["b"]));
    Assert.same(["f", "c"], group.getDependencySortedVariables(["c"]));
    Assert.same(["f", "c", "e", "d", "b"], group.getDependencySortedVariables(["b", "c"]));
    Assert.same(["z", "y", "x"], group.getDependencySortedVariables(["x"]));
  }

  public function testEvaluate() {
    var expressionGroup = new ExpressionGroup([
      'MAP_1' => '2 * SOURCE_1 + 3 * SOURCE_2',
      'MAP_2' => '0.5 * SOURCE_1 + 10 * MAP_1',
      'MAP_3' => '0.2 * MAP_1 + 0.3 * MAP_2',
    ]);
    var source1 = 2.34;
    var source2 = 3.14;
    var result = expressionGroup.evaluate([
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
    ]);
    var expectedMap1 = 2 * source1 + 3 * source2;
    var expectedMap2 = 0.5 * source1 + 10 * expectedMap1;
    var expectedMap3 = 0.2 * expectedMap1 + 0.3 * expectedMap2;
    var expected : Map<String, Value> = [
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
      'MAP_1' => expectedMap1,
      'MAP_2' => expectedMap2,
      'MAP_3' => expectedMap3,
    ];
    Assert.isTrue(expected.equals(result));
  }

  public function testCanExpand() {
    var group = new ExpressionGroup([
      'A' => 1,
      'B' => 2,
      'AB' => 'A * B'
    ]);
    Assert.isTrue(group.canExpand());
  }

  public function testExpand() {
    var expressionGroup = new ExpressionGroup([
      'A' => 1,
      'B' => 2,
      'C' => 3,
      'D' => 4,
      'A_PLUS_B' => 'A + B',
      'B_PLUS_C' => 'B + C',
      'C_PLUS_D' => 'C + D',
      'X_PLUS_Y' => 'X + Y',
      'A_PLUS_B_PLUS_X' => 'A_PLUS_B + X'
    ]);
    Assert.isTrue(expressionGroup.canExpand());
    var result = expressionGroup.expand();
    Assert.same({
      A: 1,
      A_PLUS_B: '(1 + 2)',
      A_PLUS_B_PLUS_X: '((1 + 2) + X)',
      B: 2,
      B_PLUS_C: '(2 + 3)',
      C: 3,
      C_PLUS_D: '(3 + 4)',
      D: 4,
      X_PLUS_Y: '(X + Y)',
    }, result.toObject());

    var simplified = result.simplify();
    Assert.same({
      A: 1,
      A_PLUS_B: 3,
      A_PLUS_B_PLUS_X: '(3 + X)',
      B: 2,
      B_PLUS_C: 5,
      C: 3,
      C_PLUS_D: 7,
      D: 4,
      X_PLUS_Y: '(X + Y)',
    }, simplified.toObject());
  }

  public function testExpand2() {
    var group = new ExpressionGroup([
      'dfs!SALES$0' => 'CapIQ!IQ_REV + IFNA0(CapIQ!IQ_OTHER_REV)',
      'dfs!SALES$1' => 'CapIQ!IQ_TOTAL_REV',
      'dfs!SALES' => 'COALESCE(dfs!SALES$0,dfs!SALES$1)'
    ]);
    group = group.expand();
    Assert.same('COALESCE((CapIQ!IQ_REV + IFNA0(CapIQ!IQ_OTHER_REV)), CapIQ!IQ_TOTAL_REV)', group.getExpression('dfs!SALES').toString());
  }

  public function testExpand3() {
    var expressions = getProcessedFinancialExpressions();
    var group = new ExpressionGroup(expressions);
    group = group.expand();
    Assert.pass();
  }

  public function testExpandExpressionForVariable() {
    var group = new ExpressionGroup([
      "a" => "b + c",
      "b" => "c + d",
      "c" => "e"
    ]);
    group = group.expandExpressionForVariable("a");
    Assert.same("((e + d) + e)", group.getExpression("a").toString());
  }

  public function testExpandExpressionForVariable2() {
    var group = new ExpressionGroup([
      'ratios_ebitda_margin' => 'asn_ebitda / asn_sales',
      'ratios_ni_margin' => 'asn_ni / asn_sales',
      'asn_ebitda' => 'fs_ebitda',
      'asn_ni' => 'fs_ni',
      'asn_sales' => 'fs_sales',
      'fs_ebitda' => 'iq_ebitda',
      'fs_sales' => 'iq_sales',
      'fs_ni' => 'iq_ni',
    ]);

    group = group.expandExpressionForVariable("ratios_ebitda_margin");
    Assert.same('(iq_ebitda / iq_sales)', group.getExpression("ratios_ebitda_margin").toString());
  }

  public function testValidate() {
    // TODO: check for cycles
    Assert.pass();
  }

  public function testFromFallbackMap() {
    var group = ExpressionGroup.fromFallbackMap([
      "a" => ["b + c", "d + e"],
      "b" => ["c + d"]
    ]);
    Assert.isTrue(group.hasVariable("a"));
    Assert.isTrue(group.hasVariable("b"));
    Assert.same("COALESCE((b + c), (d + e))", group.getExpression("a").toString());
    Assert.same("(c + d)", group.getExpression("b").toString());
  }

  public function testGetEvaluationInfo() {
    var group = new ExpressionGroup([
      'ratios_ebitda_margin' => 'asn_ebitda / asn_sales',
      'ratios_ni_margin' => 'asn_ni / asn_sales',
      'asn_ebitda' => 'fs_ebitda',
      'asn_ni' => 'fs_ni',
      'asn_sales' => 'fs_sales',
      'fs_ebitda' => 'iq_ebitda',
      'fs_ni' => 'iq_ni',
      'fs_sales' => 'iq_sales',
    ]);
    var info = group.getEvaluationInfo(["ratios_ebitda_margin", "ratios_ni_margin"]);
    Assert.same(8, info.expressions.keys().toArray().length);
    Assert.same(info.sortedComputedVariables.length, info.expressions.keys().toArray().length);
    Assert.same({ type: "Identifier", name: "iq_ni" }, info.expressions.get("fs_ni").toObject());
    Assert.same({ type: "Identifier", name: "fs_ni" }, info.expressions.get("asn_ni").toObject());
    Assert.same({ type: "Identifier", name: "iq_sales" }, info.expressions.get("fs_sales").toObject());
    Assert.same({ type: "Identifier", name: "iq_ebitda" }, info.expressions.get("fs_ebitda").toObject());
    Assert.same({ type: "Identifier", name: "fs_sales" }, info.expressions.get("asn_sales").toObject());
    Assert.same({
      type: "Binary",
      operator: "/",
      left: { type: "Identifier", name: "asn_ni" },
      right: { type: "Identifier", name: "asn_sales" }
    }, info.expressions.get("ratios_ni_margin").toObject());
    Assert.same({ type: "Identifier", name: "fs_ebitda" }, info.expressions.get("asn_ebitda").toObject());
    Assert.same({
      type: "Binary",
      operator: "/",
      left: { type: "Identifier", name: "asn_ebitda" },
      right: { type: "Identifier", name: "asn_sales" }
    }, info.expressions.get("ratios_ebitda_margin").toObject());
    Assert.same(["iq_ebitda", "iq_sales", "iq_ni"], info.externalVariables);
    Assert.same(["fs_ni", "asn_ni", "fs_sales", "fs_ebitda", "asn_sales", "ratios_ni_margin", "asn_ebitda", "ratios_ebitda_margin"], info.sortedComputedVariables);
  }

  public function testGetEvaluationInfo2() {
    var group = new ExpressionGroup([
      'ratios_ebitda_margin' => 'asn_ebitda / asn_sales',
      'ratios_ni_margin' => 'asn_ni / asn_sales',
      'asn_ebitda' => 'fs_ebitda',
      'asn_ni' => 'fs_ni',
      'asn_sales' => 'fs_sales',
      'fs_ebitda' => 'iq_ebitda',
      'fs_ni' => 'iq_ni',
      'fs_sales' => 'iq_sales',
    ]);
    var info = group.getEvaluationInfo(["ratios_ebitda_margin"]);
    Assert.same(5, info.expressions.keys().toArray().length);
    Assert.same(info.sortedComputedVariables.length, info.expressions.keys().toArray().length);
    Assert.same({ type: "Identifier", name: "iq_sales" }, info.expressions.get("fs_sales").toObject());
    Assert.same({ type: "Identifier", name: "iq_ebitda" }, info.expressions.get("fs_ebitda").toObject());
    Assert.same({ type: "Identifier", name: "fs_sales" }, info.expressions.get("asn_sales").toObject());
    Assert.same({ type: "Identifier", name: "fs_ebitda" }, info.expressions.get("asn_ebitda").toObject());
    Assert.same({
      type: "Binary",
      operator: "/",
      left: { type: "Identifier", name: "asn_ebitda" },
      right: { type: "Identifier", name: "asn_sales" }
    }, info.expressions.get("ratios_ebitda_margin").toObject());
    Assert.same(["iq_ebitda", "iq_sales"], info.externalVariables);
    Assert.same(["fs_sales", "fs_ebitda", "asn_sales", "asn_ebitda", "ratios_ebitda_margin"], info.sortedComputedVariables);
  }

  public function testGetEvaluationInfo3() {
    var group = new ExpressionGroup([
      'ratios_ebitda_margin' => 'asn_ebitda / asn_sales',
      'ratios_ni_margin' => 'asn_ni / asn_sales',
      'asn_ebitda' => 'fs_ebitda',
      'asn_ni' => 'fs_ni',
      'asn_sales' => 'fs_sales',
      'fs_ebitda' => 'iq_ebitda',
      'fs_ni' => 'iq_ni',
      'fs_sales' => 'iq_sales',
    ]);
    var info = group.getEvaluationInfo(["asn_ni", "fs_sales"]);
    Assert.same(3, info.expressions.keys().toArray().length);
    Assert.same(info.sortedComputedVariables.length, info.expressions.keys().toArray().length);
    Assert.same({ type: "Identifier", name: "iq_ni" }, info.expressions.get("fs_ni").toObject());
    Assert.same({ type: "Identifier", name: "fs_ni" }, info.expressions.get("asn_ni").toObject());
    Assert.same({ type: "Identifier", name: "iq_sales" }, info.expressions.get("fs_sales").toObject());
    Assert.same(["iq_ni", "iq_sales"], info.externalVariables);
    Assert.same(["fs_sales", "fs_ni", "asn_ni"], info.sortedComputedVariables);
  }

  function getProcessedFinancialExpressions() : Map<String, ExpressionOrValue> {
    var data = getFinancialExpressions();
    return Reflect.fields(data).reduce(function(acc : Map<String, ExpressionOrValue>, fieldId) {
      var expressionStrings : Array<String> = Reflect.field(data, fieldId);
      var subFieldIds : Array<String> = [];
      var i = 0;
      for (expressionString in expressionStrings) {
        var subFieldId = '${fieldId}$$${i}';
        subFieldIds.push(subFieldId);
        acc.set(subFieldId, expressionString);
        i++;
      }
      var topLevelExpressionString = subFieldIds.length > 1 ?
        'COALESCE(${subFieldIds.join(", ")})' :
        subFieldIds[0];
      acc.set(fieldId, topLevelExpressionString);
      return acc;
    }, new Map());
  }

  function getFinancialExpressions() {
    return {
      "dfs!OP_INC": [
        "dfs!GROSS_PROFIT - dfs!SGA - dfs!OTHER_OP_EXP_INC",
        "CapIQ!IQ_OPER_INC"
      ],
      "dfs!GROSS_PROFIT": [
        "dfs!SALES - dfs!COGS",
        "CapIQ!IQ_GP"
      ],
      "dfs!COGS": [
        "CapIQ!IQ_COGS + IFNA0(CapIQ!IQ_FIN_DIV_EXP) + IFNA0(CapIQ!IQ_FIN_DIV_INT_EXP) +  IFNA0(CapIQ!IQ_INS_DIV_EXP)",
        "CapIQ!IQ_COST_REV"
      ],
      "dfs!AMORT": [
        "CapIQ!IQ_GW_INTAN_AMORT_CF + CapIQ!IQ_OIL_IMPAIR"
      ],
      "dfs!ACC_REC": [
        "CapIQ!IQ_TOTAL_RECEIV"
      ],
      "dfs!ACC_PAY": [
        "CapIQ!IQ_AP"
      ],
      "dfs!AD_EXP": [
        "CapIQ!IQ_ADVERTISING"
      ],
      "dfs!CASH_ST_INV": [
        "CapIQ!IQ_CASH_EQUIV + CapIQ!IQ_ST_INVEST + CapIQ!IQ_TRADING_ASSETS",
        "CapIQ!IQ_CASH_ST_INVEST"
      ],
      "dfs!BOOK_CAP": [
        "dfs!DEBT + dfs!SH_EQUITY"
      ],
      "dfs!BASIC_WT_AVG_SHARES": [
        "CapIQ!IQ_BASIC_WEIGHT"
      ],
      "dfs!CAPEX": [
        "CapIQ!IQ_CAPEX"
      ],
      "dfs!CHG_DEBT": [
        "dfs!CHG_ST_DEBT + dfs!CHG_LT_DEBT",
        "dfs!INC_DEBT - dfs!DEC_DEBT"
      ],
      "dfs!CF_OP": [
        "dfs!NET_INC_CF + dfs!DA_CF + dfs!CHANGE_WC + dfs!OTHER_OP_ACT",
        "CapIQ!IQ_CASH_OPER"
      ],
      "dfs!CF_INV": [
        "dfs!CAPEX + dfs!DISPOSAL + dfs!OTHER_INV_ACT",
        "CapIQ!IQ_CASH_INVEST"
      ],
      "dfs!CF_FIN": [
        "dfs!DVD_PAID + dfs!CHG_DEBT + dfs!CHG_EQUITY + dfs!SPECIAL_DVD_PAID + dfs!OTHER_FIN_ACT",
        "CapIQ!IQ_CASH_FINAN"
      ],
      "dfs!CHANGE_WC": [
        "CapIQ!IQ_CHANGE_NET_OPER_ASSETS"
      ],
      "dfs!CHANGE_CASH": [
        "dfs!CF_OP + dfs!CF_INV + dfs!CF_FIN + dfs!OTHER_CF_ADJ",
        "CapIQ!IQ_NET_CHANGE"
      ],
      "dfs!CHG_LT_DEBT": [
        "dfs!INC_LT_DEBT - dfs!DEC_LT_DEBT"
      ],
      "dfs!CHG_EQUITY": [
        "dfs!EQUITY_ISS - dfs!SHARE_REPO"
      ],
      "dfs!CHG_ST_DEBT": [
        "dfs!INC_ST_DEBT - dfs!DEC_ST_DEBT"
      ],
      "dfs!DISCONT_OPER": [
        "IFNA0(CapIQ!IQ_DO)"
      ],
      "dfs!DEBT": [
        "dfs!ST_DEBT + dfs!LT_DEBT",
        "CapIQ!IQ_TOTAL_DEBT"
      ],
      "dfs!DA": [
        "dfs!DEPN + dfs!AMORT",
        "CapIQ!IQ_DA_CF"
      ],
      "dfs!COMMON_EQUITY": [
        "dfs!SHARE_CAP + dfs!RET_EARN + dfs!OTHER_EQUITY",
        "CapIQ!IQ_TOTAL_COMMON_EQUITY"
      ],
      "dfs!DA_CF": [
        "CapIQ!IQ_DA_SUPPL_CF + CapIQ!IQ_GW_INTAN_AMORT_CF + IFNA0(CapIQ!IQ_OIL_IMPAIR)",
        "CapIQ!IQ_DA_CF"
      ],
      "dfs!DEPN": [
        "CapIQ!IQ_DA_SUPPL_CF"
      ],
      "dfs!DEC_LT_DEBT": [
        "CapIQ!IQ_LT_DEBT_REPAID"
      ],
      "dfs!DEC_DEBT": [
        "dfs!DEC_ST_DEBT + dfs!DEC_ST_DEBT"
      ],
      "dfs!DEC_ST_DEBT": [
        "CapIQ!IQ_ST_DEBT_REPAID"
      ],
      "dfs!DILUTED_WT_AVG_SHARES": [
        "CapIQ!IQ_DILUT_WEIGHT"
      ],
      "dfs!EBITDAR": [
        "dfs!OP_INC + dfs!DA + dfs!RENT",
        "CapIQ!IQ_EBITDAR"
      ],
      "dfs!EBITA": [
        "dfs!OP_INC + dfs!AMORT",
        "CapIQ!EBITA"
      ],
      "dfs!DVD_PAID": [
        "CapIQ!IQ_COMMON_DIV_CF + CapIQ!IQ_PREF_DIV_CF",
        "CapIQ!IQ_COMMON_PREF_DIV_CF",
        "CapIQ!IQ_TOTAL_DIV_PAID_CF"
      ],
      "dfs!DISPOSAL": [
        "CapIQ!IQ_SALE_PPE_CF"
      ],
      "dfs!DISCRETIONARY_CF": [
        "dfs!FCF - dfs!DVD_PAID"
      ],
      "dfs!EBIT": [
        "dfs!OP_INC",
        "CapIQ!EBIT"
      ],
      "dfs!EBITDA": [
        "dfs!OP_INC + dfs!DA",
        "CapIQ!IQ_EBITDA"
      ],
      "dfs!FCF": [
        "dfs!CF_OP - dfs!CAPEX",
        "CapIQ!IQ_LEVERED_FCF"
      ],
      "dfs!EV_COMPONENTS": [
        "dfs!NET_DEBT + dfs!PREF_EQUITY + dfs!MIN_INT_BS"
      ],
      "dfs!EMPLOYED_CAPITAL": [
        "dfs!NET_WORKING_CAP + dfs!NET_FIXED"
      ],
      "dfs!EBT": [
        "dfs!OP_INC - dfs!NET_INT_EXP + dfs!OTHER_INC",
        "CapIQ!IQ_EBT"
      ],
      "dfs!EQUITY_ISS": [
        "CapIQ!IQ_COMMON_ISSUED + CapIQ!IQ_PREF_ISSUED"
      ],
      "dfs!EV_COMPONENTS_EX_CASH_AND_MINORITY_INT": [
        "dfs!EV_COMPONENTS - dfs!CASH_ST_INV - dfs!MIN_INT_BS"
      ],
      "dfs!EV_COMPONENTS_EX_CASH": [
        "dfs!EV_COMPONENTS - dfs!CASH_ST_INV"
      ],
      "dfs!EV_COMPONENTS_EX_MINORITY_INT": [
        "dfs!EV_COMPONENTS - dfs!MIN_INT_BS"
      ],
      "dfs!FFO": [
        "dfs!CF_OP - dfs!CHANGE_WC"
      ],
      "dfs!FCF_EQUITY": [
        "dfs!FCF + dfs!CHG_DEBT"
      ],
      "dfs!GOODWILL": [
        "CapIQ!IQ_GW"
      ],
      "dfs!MINORITY_INT_IS": [
        "IFNA0(CapIQ!IQ_MINORITY_INTEREST_IS)"
      ],
      "dfs!INV": [
        "CapIQ!IQ_INVENTORY"
      ],
      "dfs!INC_TAX": [
        "CapIQ!IQ_INC_TAX"
      ],
      "dfs!INC_LT_DEBT": [
        "CapIQ!IQ_LT_DEBT_ISSUED"
      ],
      "dfs!INC_DEBT": [
        "dfs!INC_ST_DEBT + dfs!INC_LT_DEBT",
        "CapIQ!IQ_TOTAL_DEBT_ISSUED"
      ],
      "dfs!INC_ST_DEBT": [
        "CapIQ!IQ_ST_DEBT_ISSUED"
      ],
      "dfs!INT_EXP": [
        "CapIQ!IQ_INTEREST_EXP"
      ],
      "dfs!INTANG_ASSETS": [
        "dfs!GOODWILL + dfs!OTHER_INTANG"
      ],
      "dfs!INT_INC": [
        "CapIQ!IQ_INTEREST_INVEST_INC"
      ],
      "dfs!LT_DEBT": [
        "CapIQ!IQ_LT_DEBT"
      ],
      "dfs!LT_ASSETS": [
        "dfs!NET_FIXED + dfs!LT_INV + dfs!GOODWILL + dfs!OTHER_INTANG + dfs!OTHER_LT_ASSETS"
      ],
      "dfs!INVESTED_CAPITAL": [
        "dfs!NET_WORKING_CAP + dfs!NET_FIXED + dfs!GOODWILL + dfs!OTHER_INTANG"
      ],
      "dfs!LT_INV": [
        "CapIQ!IQ_LT_INVEST"
      ],
      "dfs!LT_LIAB": [
        "dfs!LT_DEBT + dfs!OTHER_LT_LIAB"
      ],
      "dfs!NET_INC_CONT": [
        "dfs!EBT - dfs!INC_TAX",
        "CapIQ!IQ_EARNING_CO"
      ],
      "dfs!NET_INC": [
        "dfs!NET_INC_CONT - dfs!DISCONT_OPER - dfs!XO",
        "CapIQ!IQ_NI_COMPANY"
      ],
      "dfs!NET_DEBT": [
        "dfs!DEBT - dfs!CASH_ST_INV",
        "CapIQ!IQ_NET_DEBT"
      ],
      "dfs!NET_BOOK_CAP": [
        "dfs!BOOK_CAP - dfs!CASH_ST_INV"
      ],
      "dfs!MIN_INT_BS": [
        "CapIQ!IQ_MINORITY_INTEREST"
      ],
      "dfs!NET_CAPEX": [
        "dfs!CAPEX - dfs!DISPOSAL"
      ],
      "dfs!NET_FIXED": [
        "CapIQ!IQ_GPPE - CapIQ!IQ_AD",
        "CapIQ!IQ_NPPE"
      ],
      "dfs!NET_INC_COMMON": [
        "dfs!NET_INC - dfs!MINORITY_INT_IS - dfs!PREF_DIV",
        "CapIQ!IQ_NI_AVAIL_INCL"
      ],
      "dfs!NET_INC_CF": [
        "CapIQ!IQ_NI_CF"
      ],
      "dfs!NET_WORKING_CAP": [
        "dfs!ACC_REC + dfs!INV + dfs!OTHER_ST_ASSETS - dfs!ACC_PAY - dfs!OTHER_ST_LIAB",
        "dfs!ST_ASSETS - dfs!CASH_ST_INV - dfs!ACC_PAY - dfs!OTHER_ST_LIAB",
        "CapIQ!IQ_NET_WORKING_CAP"
      ],
      "dfs!NET_INT_EXP": [
        "CapIQ!IQ_INTEREST_EXP - IFNA0(CapIQ!IQ_INTEREST_INVEST_INC)",
        "CapIQ!IQ_NET_INTEREST_EXP"
      ],
      "dfs!NORM_NET_INC": [
        "dfs!NET_INC_COMMON + dfs!DISCONT_OPER + dfs!XO",
        "CapIQ!IQ_NI_AVAIL_EXCL"
      ],
      "dfs!OPERATING_ASSETS": [
        "dfs!ACC_REC + dfs!INV + dfs!OTHER_ST_ASSETS + dfs!NET_FIXED"
      ],
      "dfs!SALES": [
        "CapIQ!IQ_REV + IFNA0(CapIQ!IQ_OTHER_REV)",
        "CapIQ!IQ_TOTAL_REV"
      ],
      "dfs!RD": [
        "CapIQ!IQ_RD_EXP"
      ],
      "dfs!OTHER_OP_EXP_INC": [
        "IFNA0(CapIQ!IQ_DA) + IFNA0(CapIQ!IQ_RD_EXP) + IFNA0(CapIQ!IQ_OTHER_OPER)",
        "CapIQ!IQ_TOTAL_OTHER_OPER - CapIQ!IQ_SGA"
      ],
      "dfs!OTHER_INTANG": [
        "CapIQ!IQ_OTHER_INTAN"
      ],
      "dfs!OTHER_FIN_ACT": [
        "IFNA0(CapIQ!IQ_OTHER_FINANCE_ACT_SUPPL)"
      ],
      "dfs!OTHER_EQUITY": [
        "CapIQ!IQ_TREASURY + CapIQ!OTHER_EQUITY"
      ],
      "dfs!OTHER_CF_ADJ": [
        "IFNA0(CapIQ!IQ_FX) + IFNA0(CapIQ!IQ_MISC_ADJUST_CF)"
      ],
      "dfs!OTHER_INC": [
        "IFNA0(CapIQ!IQ_INC_EQUITY) + IFNA0(CapIQ!IQ_CURRENCY_GAIN) + IFNA0(CapIQ!IQ_OTHER_NON_OPER_EXP_SUPPL) +  IFNA0(CapIQ!IQ_MERGER_RESTRUCTURE) + IFNA0(CapIQ!IQ_IMPAIRMENT_GW) + IFNA0(CapIQ!IQ_GAIN_INVEST) +  IFNA0(CapIQ!IQ_GAIN_ASSETS) + IFNA0(CapIQ!IQ_OTHER_UNUSUAL)",
        "IFNA0(CapIQ!IQ_OTHER_NON_OPER_EXP) + IFNA0(CapIQ!IQ_TOTAL_UNUSUAL)"
      ],
      "dfs!OTHER_LT_LIAB": [
        "IFNA0(CapIQ!IQ_CAPITAL_LEASES) + IFNA0(CapIQ!IQ_FIN_DIV_DEBT_LT) +  IFNA0(CapIQ!IQ_FIN_DIV_LIAB_LT) + IFNA0(CapIQ!IQ_OTHER_LIAB)"
      ],
      "dfs!OTHER_LT_ASSETS": [
        "IFNA0(CapIQ!IQ_FIN_DIV_LOANS_LT) + IFNA0(CapIQ!IQ_FIN_DIV_ASSETS_LT) + IFNA0(CapIQ!IQ_OTHER_ASSETS)"
      ],
      "dfs!OTHER_INV_ACT": [
        "CapIQ!IQ_CASH_ACQUIRE_CF + CapIQ!IQ_DIVEST_CF + CapIQ!OTHER_INVEST_ACT"
      ],
      "dfs!OTHER_OP_ACT": [
        "CapIQ!IQ_NON_CASH_ITEMS + IFNA0(CapIQ!IQ_OTHER_AMORT)"
      ],
      "dfs!OTHER_ST_LIAB": [
        "IFNA0(CapIQ!IQ_AE) + IFNA0(CapIQ!IQ_FIN_DIV_DEBT_CURRENT) + IFNA0(CapIQ!IQ_FIN_DIV_LIAB_CURRENT) +  IFNA0(CapIQ!IQ_OTHER_CL) + IFNA0(CapIQ!IQ_CURRENT_PORT)"
      ],
      "dfs!OTHER_ST_ASSETS": [
        "IFNA0(CapIQ!IQ_PREPAID_EXP) + IFNA0(CapIQ!IQ_FIN_DIV_LOANS_CURRENT) +  IFNA0(CapIQ!IQ_FIN_DIV_ASSETS_CURRENT) + IFNA0(CapIQ!IQ_LOANS_FOR_SALE) +  IFNA0(CapIQ!IQ_DEF_TAX_ASSETS_CURRENT) + IFNA0(CapIQ!IQ_RESTRICTED_CASH) +  IFNA0(CapIQ!IQ_OTHER_CA_SUPPL)"
      ],
      "dfs!PREF_DIV": [
        "IFNA0(CapIQ!IQ_PREF_DIV_OTHER)"
      ],
      "dfs!PREF_EQUITY": [
        "CapIQ!IQ_PREF_EQUITY"
      ],
      "dfs!REPORTED_BASIC_EPS": [
        "CapIQ!IQ_BASIC_EPS_INCL"
      ],
      "dfs!RENT": [
        "CapIQ!IQ_NET_RENTAL_EXP_FN"
      ],
      "dfs!REPORTED_DILUTED_EPS": [
        "CapIQ!IQ_DILUT_EPS_INCL"
      ],
      "dfs!RET_EARN": [
        "CapIQ!IQ_RE"
      ],
      "dfs!TOTAL_LIAB_EQUITY": [
        "dfs!TOTAL_LIAB + dfs!SH_EQUITY",
        "CapIQ!IQ_TOTAL_LIAB_EQUITY"
      ],
      "dfs!ST_DEBT": [
        "CapIQ!IQ_ST_DEBT"
      ],
      "dfs!SH_EQUITY": [
        "dfs!PREF_EQUITY + dfs!COMMON_EQUITY + dfs!MIN_INT_BS",
        "CapIQ!IQ_TOTAL_EQUITY"
      ],
      "dfs!SHARE_CAP": [
        "CapIQ!IQ_COMMON + CapIQ!IQ_APIC"
      ],
      "dfs!SGA": [
        "CapIQ!IQ_SGA_SUPPL + IFNA0(CapIQ!IQ_EXPLORE_DRILL) + IFNA0(CapIQ!IQ_PROV_BAD_DEBTS) +  IFNA0(CapIQ!IQ_STOCK_BASED) + IFNA0(CapIQ!IQ_PRE_OPEN_COST)",
        "CapIQ!IQ_SGA"
      ],
      "dfs!SHAREHOLDER_PAYOUT": [
        "dfs!DVD_PAID + dfs!SPECIAL_DVD_PAID + dfs!SHARE_REPO"
      ],
      "dfs!SHARE_REPO": [
        "CapIQ!IQ_COMMON_REP + CapIQ!IQ_PREF_REP"
      ],
      "dfs!STOCK_COMP": [
        "CapIQ!IQ_STOCK_BASED"
      ],
      "dfs!SPECIAL_DVD_PAID": [
        "IFNA0(CapIQ!ID_SPECIAL_DIV_CF)"
      ],
      "dfs!ST_ASSETS": [
        "dfs!CASH_ST_INV + dfs!ACC_REC + dfs!INV + dfs!OTHER_ST_ASSETS",
        "CapIQ!IT_TOTAL_CA"
      ],
      "dfs!TOTAL_ASSETS": [
        "dfs!ST_ASSETS + dfs!LT_ASSETS",
        "CapIQ!IQ_TOTAL_ASSETS"
      ],
      "dfs!TANG_ASSETS": [
        "dfs!TOTAL_ASSETS - dfs!INTANG_ASSETS"
      ],
      "dfs!ST_LIAB": [
        "dfs!ACC_PAY + dfs!ST_DEBT + dfs!OTHER_ST_LIAB",
        "CapIQ!IQ_TOTAL_CL"
      ],
      "dfs!TANG_BOOK_EQUITY": [
        "dfs!SH_EQUITY + dfs!INTANG_ASSETS"
      ],
      "dfs!TOTAL_CAPITAL": [
        "dfs!BOOK_CAP + dfs!PREF_EQUITY + dfs!MIN_INT_BS",
        "CapIQ!IQ_TOTAL_CAP"
      ],
      "dfs!TOTAL_ASSETS_EX_CASH": [
        "dfs!TOTAL_ASSETS - dfs!CASH_ST_INV"
      ],
      "dfs!TOTAL_LIAB": [
        "dfs!ST_LIAB + dfs!LT_LIAB",
        "CapIQ!IQ_TOTAL_LIAB"
      ],
      "ratios!GROSS_PROFIT_PER_SHARE": [
        "dfs!GROSS_PROFIT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!EBITDAR_PER_SHARE": [
        "dfs!EBITDAR / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!COGS_PER_SHARE": [
        "dfs!COGS / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!ACC_REC_PER_SHARE": [
        "dfs!ACC_REC / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!ACC_PAY_PER_SHARE": [
        "dfs!ACC_PAY / dfs!BASIC_WT_AVG_SHARES"
      ],
      "dfs!XO": [
        "IFNA0(CapIQ!IQ_EXTRA_ACC_ITEMS)"
      ],
      "ratios!ACC_PAY_PER_DILUTED_SHARE": [
        "dfs!ACC_PAY / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!ACC_REC_PER_DILUTED_SHARE": [
        "dfs!ACC_REC / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!CASH_ST_INV_PER_SHARE": [
        "dfs!CASH_ST_INV / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!CASH_ST_INV_PER_DILUTED_SHARE": [
        "dfs!CASH_ST_INV / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!COGS_PER_DILUTED_SHARE": [
        "dfs!COGS / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!DA_PER_SHARE": [
        "dfs!DA / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!COMMON_EQUITY_PER_SHARE": [
        "dfs!COMMON_EQUITY / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!COMMON_EQUITY_PER_DILUTED_SHARE": [
        "dfs!COMMON_EQUITY / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!DA_PER_DILUTED_SHARE": [
        "dfs!DA / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBITA_PER_SHARE": [
        "dfs!EBITA / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!DEBT_PER_SHARE": [
        "dfs!DEBT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!DEBT_PER_DILUTED_SHARE": [
        "dfs!DEBT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBITA_PER_DILUTED_SHARE": [
        "dfs!EBITA / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBITA_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!EBITDAR_PER_DILUTED_SHARE": [
        "dfs!EBITDAR / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBITDAR_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!EBIT_PER_SHARE": [
        "dfs!EBIT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!EBITDA_PER_SHARE": [
        "dfs!EBITDA / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!EBITDA_PER_DILUTED_SHARE": [
        "dfs!EBITDA / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBITDA_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!EBIT_PER_DILUTED_SHARE": [
        "dfs!EBIT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EBIT_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!GOODWILL_PER_SHARE": [
        "dfs!GOODWILL / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!EBT_PER_SHARE": [
        "dfs!EBT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!EBT_PER_DILUTED_SHARE": [
        "dfs!EBT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!GOODWILL_PER_DILUTED_SHARE": [
        "dfs!GOODWILL / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!EFFECTIVE_TAX_RATE": [
        "dfs!INC_TAX / dfs!EBT"
      ],
      "ratios!GROSS_PROFIT_PER_DILUTED_SHARE": [
        "dfs!GROSS_PROFIT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!GROSS_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!NET_INC_PER_SHARE": [
        "dfs!NET_INC / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!LT_INV_PER_SHARE": [
        "dfs!LT_INV / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!LT_ASSETS_PER_SHARE": [
        "dfs!LT_ASSETS / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!INV_PER_SHARE": [
        "dfs!INV / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!INV_PER_DILUTED_SHARE": [
        "dfs!INV / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!LT_ASSETS_PER_DILUTED_SHARE": [
        "dfs!LT_ASSETS / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!LT_DEBT_PER_SHARE": [
        "dfs!LT_DEBT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!LT_DEBT_PER_DILUTED_SHARE": [
        "dfs!LT_DEBT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!LT_INV_PER_DILUTED_SHARE": [
        "dfs!LT_INV / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_INC_CONT_PER_DILUTED_SHARE": [
        "dfs!NET_INC_CONT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_DEBT_PER_SHARE": [
        "dfs!NET_DEBT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!LT_LIAB_PER_SHARE": [
        "dfs!LT_LIAB / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!LT_LIAB_PER_DILUTED_SHARE": [
        "dfs!LT_LIAB / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_DEBT_PER_DILUTED_SHARE": [
        "dfs!NET_DEBT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_INC_COMMON_PER_DILUTED_SHARE": [
        "dfs!NET_INC_COMMON / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_FIXED_PER_SHARE": [
        "dfs!NET_FIXED / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NET_FIXED_PER_DILUTED_SHARE": [
        "dfs!NET_FIXED / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NET_INC_COMMON_PER_SHARE": [
        "dfs!NET_INC_COMMON / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NET_INC_CONT_PER_SHARE": [
        "dfs!NET_INC_CONT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NET_INC_PER_DILUTED_SHARE": [
        "dfs!NET_INC / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!OP_INC_PER_SHARE": [
        "dfs!OP_INC / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NORM_NET_INC_PER_SHARE": [
        "dfs!NORM_NET_INC / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NET_INT_EXP_PER_SHARE": [
        "dfs!NET_INT_EXP / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!NET_INT_EXP_PER_DILUTED_SHARE": [
        "dfs!NET_INT_EXP / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!NOPAT": [
        "dfs!EBIT * (1 - ratios!EFFECTIVE_TAX_RATE)"
      ],
      "ratios!NET_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!NORM_NET_INC_PER_DILUTED_SHARE": [
        "dfs!NORM_NET_INC / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!OPERATING_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!NORM_NET_MARGIN": [
        "dfs!NET_INC_CONT / dfs!SALES"
      ],
      "ratios!OP_INC_PER_DILUTED_SHARE": [
        "dfs!OP_INC / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!ST_DEBT_PER_SHARE": [
        "dfs!ST_DEBT / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!ST_ASSETS_PER_DILUTED_SHARE": [
        "dfs!ST_ASSETS / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!SALES_PER_SHARE": [
        "dfs!SALES / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!SALES_PER_DILUTED_SHARE": [
        "dfs!SALES / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!SH_EQUITY_PER_SHARE": [
        "dfs!SH_EQUITY / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!SH_EQUITY_PER_DILUTED_SHARE": [
        "dfs!SH_EQUITY / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!ST_ASSETS_PER_SHARE": [
        "dfs!ST_ASSETS / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!ST_DEBT_PER_DILUTED_SHARE": [
        "dfs!ST_DEBT / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!TOTAL_ASSETS_PER_DILUTED_SHARE": [
        "dfs!TOTAL_ASSETS / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!ST_LIAB_PER_SHARE": [
        "dfs!ST_LIAB / dfs!BASIC_WT_AVG_SHARES"
      ],
      "ratios!ST_LIAB_PER_DILUTED_SHARE": [
        "dfs!ST_LIAB / dfs!DILUTED_WT_AVG_SHARES"
      ],
      "ratios!TOTAL_ASSETS_PER_SHARE": [
        "dfs!TOTAL_ASSETS / dfs!BASIC_WT_AVG_SHARES"
      ]
    };
  }
}
