import SwiftUI

struct FormulaGuideView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 页面标题
                    Text("formula_guide_title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // 几何形体计算公式
                    GeometryFormulasSection()

                    // 单位换算
                    UnitConversionsSection()

                    // 数量关系计算公式
                    QuantityRelationsSection()

                    // 算术运算定律
                    ArithmeticLawsSection()

                    // 特殊问题
                    SpecialProblemsSection()
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("back".localized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - 几何形体计算公式
struct GeometryFormulasSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "geometry_formulas_title".localized)

            // 平面图形
            SubsectionHeader(title: "plane_figures_title".localized)

            FormulaGroup(title: "rectangle".localized, formulas: [
                "perimeter_formula".localized + ": C = (a + b) × 2",
                "area_formula".localized + ": S = ab"
            ])

            FormulaGroup(title: "square".localized, formulas: [
                "perimeter_formula".localized + ": C = 4a",
                "area_formula".localized + ": S = a² = a × a"
            ])

            FormulaGroup(title: "triangle".localized, formulas: [
                "area_formula".localized + ": S = ah ÷ 2",
                "interior_angles_sum".localized + ": 180°"
            ])

            FormulaGroup(title: "parallelogram".localized, formulas: [
                "area_formula".localized + ": S = ah"
            ])

            FormulaGroup(title: "trapezoid".localized, formulas: [
                "area_formula".localized + ": S = (a + b)h ÷ 2"
            ])

            FormulaGroup(title: "circle".localized, formulas: [
                "diameter_formula".localized + ": d = 2r",
                "radius_formula".localized + ": r = d ÷ 2",
                "circumference_formula".localized + ": C = πd = 2πr",
                "area_formula".localized + ": S = πr²"
            ])

            // 立体图形
            SubsectionHeader(title: "solid_figures_title".localized)

            FormulaGroup(title: "cuboid".localized, formulas: [
                "volume_formula".localized + ": V = abh",
                "volume_formula_alt".localized + ": V = " + "base_area".localized + " × " + "height".localized
            ])

            FormulaGroup(title: "cube".localized, formulas: [
                "volume_formula".localized + ": V = a³ = a × a × a"
            ])

            FormulaGroup(title: "cylinder".localized, formulas: [
                "lateral_surface_area".localized + ": S = ch = πdh = 2πrh",
                "surface_area".localized + ": S = ch + 2s = 2πrh + 2πr²",
                "volume_formula".localized + ": V = Sh"
            ])

            FormulaGroup(title: "cone".localized, formulas: [
                "volume_formula".localized + ": V = ⅓Sh"
            ])
        }
        .padding(.horizontal)
    }
}

// MARK: - 单位换算
struct UnitConversionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "unit_conversions_title".localized)

            ConversionGroup(title: "length_units".localized, conversions: [
                "1 " + "kilometer".localized + " = 1000 " + "meter".localized,
                "1 " + "meter".localized + " = 10 " + "decimeter".localized,
                "1 " + "decimeter".localized + " = 10 " + "centimeter".localized,
                "1 " + "centimeter".localized + " = 10 " + "millimeter".localized
            ])

            ConversionGroup(title: "area_units".localized, conversions: [
                "1 " + "square_meter".localized + " = 100 " + "square_decimeter".localized,
                "1 " + "square_decimeter".localized + " = 100 " + "square_centimeter".localized,
                "1 " + "square_centimeter".localized + " = 100 " + "square_millimeter".localized,
                "1 " + "hectare".localized + " = 10000 " + "square_meter".localized
            ])

            ConversionGroup(title: "volume_units".localized, conversions: [
                "1 " + "cubic_meter".localized + " = 1000 " + "cubic_decimeter".localized,
                "1 " + "cubic_decimeter".localized + " = 1000 " + "cubic_centimeter".localized,
                "1 " + "liter".localized + " = 1 " + "cubic_decimeter".localized + " = 1000 " + "milliliter".localized,
                "1 " + "milliliter".localized + " = 1 " + "cubic_centimeter".localized
            ])

            ConversionGroup(title: "mass_units".localized, conversions: [
                "1 " + "ton".localized + " = 1000 " + "kilogram".localized,
                "1 " + "kilogram".localized + " = 1000 " + "gram".localized
            ])

            ConversionGroup(title: "time_units".localized, conversions: [
                "1 " + "year".localized + " = 12 " + "month".localized,
                "1 " + "day".localized + " = 24 " + "hour".localized,
                "1 " + "hour".localized + " = 60 " + "minute".localized,
                "1 " + "minute".localized + " = 60 " + "second".localized
            ])
        }
        .padding(.horizontal)
    }
}

// MARK: - 数量关系计算公式
struct QuantityRelationsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "quantity_relations_title".localized)

            FormulaGroup(title: "basic_relations".localized, formulas: [
                "unit_number".localized + " × " + "units".localized + " = " + "total".localized,
                "speed".localized + " × " + "time".localized + " = " + "distance".localized,
                "unit_price".localized + " × " + "quantity".localized + " = " + "total_price".localized,
                "work_efficiency".localized + " × " + "work_time".localized + " = " + "work_total".localized
            ])

            FormulaGroup(title: "arithmetic_operations".localized, formulas: [
                "addend".localized + " + " + "addend".localized + " = " + "sum".localized,
                "minuend".localized + " - " + "subtrahend".localized + " = " + "difference".localized,
                "factor".localized + " × " + "factor".localized + " = " + "product".localized,
                "dividend".localized + " ÷ " + "divisor".localized + " = " + "quotient".localized
            ])
        }
        .padding(.horizontal)
    }
}

// MARK: - 算术运算定律
struct ArithmeticLawsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "arithmetic_laws_title".localized)

            FormulaGroup(title: "operation_laws".localized, formulas: [
                "commutative_law_addition".localized + ": a + b = b + a",
                "associative_law_addition".localized + ": (a + b) + c = a + (b + c)",
                "commutative_law_multiplication".localized + ": a × b = b × a",
                "associative_law_multiplication".localized + ": (a × b) × c = a × (b × c)",
                "distributive_law".localized + ": a × (b + c) = a × b + a × c"
            ])

            FormulaGroup(title: "fraction_operations".localized, formulas: [
                "fraction_addition_same_denominator".localized,
                "fraction_addition_different_denominator".localized,
                "fraction_multiplication".localized,
                "fraction_division".localized
            ])
        }
        .padding(.horizontal)
    }
}

// MARK: - 特殊问题
struct SpecialProblemsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "special_problems_title".localized)

            FormulaGroup(title: "sum_difference_problem".localized, formulas: [
                "large_number_formula".localized + ": (" + "sum".localized + " + " + "difference".localized + ") ÷ 2",
                "small_number_formula".localized + ": (" + "sum".localized + " - " + "difference".localized + ") ÷ 2"
            ])

            FormulaGroup(title: "sum_multiple_problem".localized, formulas: [
                "small_number_formula".localized + ": " + "sum".localized + " ÷ (" + "multiple".localized + " + 1)",
                "large_number_formula".localized + ": " + "small_number".localized + " × " + "multiple".localized
            ])

            FormulaGroup(title: "plant_tree_problem".localized, formulas: [
                "both_ends_plant".localized + ": " + "trees".localized + " = " + "segments".localized + " + 1",
                "one_end_plant".localized + ": " + "trees".localized + " = " + "segments".localized,
                "no_end_plant".localized + ": " + "trees".localized + " = " + "segments".localized + " - 1"
            ])

            FormulaGroup(title: "meeting_problem".localized, formulas: [
                "meeting_distance".localized + " = " + "speed_sum".localized + " × " + "meeting_time".localized,
                "meeting_time".localized + " = " + "meeting_distance".localized + " ÷ " + "speed_sum".localized
            ])

            FormulaGroup(title: "chase_problem".localized, formulas: [
                "chase_distance".localized + " = " + "speed_difference".localized + " × " + "chase_time".localized,
                "chase_time".localized + " = " + "chase_distance".localized + " ÷ " + "speed_difference".localized
            ])

            FormulaGroup(title: "profit_problem".localized, formulas: [
                "profit".localized + " = " + "selling_price".localized + " - " + "cost".localized,
                "profit_rate".localized + " = " + "profit".localized + " ÷ " + "cost".localized + " × 100%"
            ])
        }
        .padding(.horizontal)
    }
}

// MARK: - 辅助视图组件
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .padding(.top, 20)
    }
}

struct SubsectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.orange)
            .padding(.top, 12)
    }
}

struct FormulaGroup: View {
    let title: String
    let formulas: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.green)

            ForEach(formulas, id: \.self) { formula in
                Text("• \(formula)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(.leading, 10)
            }
        }
        .padding(.vertical, 6)
    }
}

struct ConversionGroup: View {
    let title: String
    let conversions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.purple)

            ForEach(conversions, id: \.self) { conversion in
                Text("• \(conversion)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(.leading, 10)
            }
        }
        .padding(.vertical, 6)
    }
}

struct FormulaGuideView_Previews: PreviewProvider {
    static var previews: some View {
        FormulaGuideView()
    }
}