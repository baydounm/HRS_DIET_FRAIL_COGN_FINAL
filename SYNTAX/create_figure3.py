"""Reproduce Figure 3 from Supplementary Datasheets 1 and 3.

Requires: artifact_tool, matplotlib, numpy, python-pptx.
Run: python create_figure3.py
"""
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FormatStrFormatter
from artifact_tool import Blob, SpreadsheetFile
from pptx import Presentation
from pptx.util import Inches

ROOT = Path(__file__).resolve().parent
LABEL_FILE = ROOT / 'SUPPLEMENTARY_DATASHEET_1_REVISED(7).xlsx'
RESULT_FILE = ROOT / 'SUPPLEMENTARY_DATASHEET_3_REVISED_WITHFDR(6).xlsx'
OUT = ROOT / 'Figure_3_reproduced'

# Import spreadsheets without modifying either source.
labels_wb = SpreadsheetFile.import_xlsx(Blob.load(str(LABEL_FILE)))
labels_sheet = labels_wb.worksheets.get_item('Food_Items_All')
label_rows = labels_sheet.get_range('A1:F165').values
label_headers = label_rows[0]
labels = {str(dict(zip(label_headers, row))['Variable_Name']).upper():
          str(dict(zip(label_headers, row))['Label']).strip().title()
          for row in label_rows[1:] if row[2]}

results_wb = SpreadsheetFile.import_xlsx(Blob.load(str(RESULT_FILE)))
results_sheet = results_wb.worksheets.get_item('Supplementary_datasheet3_final')
result_rows = results_sheet.get_range('A2:N1604').values
headers = result_rows[0]
records = [dict(zip(headers, row)) for row in result_rows[1:] if row[0] is not None]

# Source figure includes all nominally significant food items for the composite outcome.
selected = [r for r in records
            if str(r['outcome']).strip().lower() == 'cind/probable dementia'
            and str(r['model']).strip().lower() == 'model 3'
            and str(r['predictor']).startswith('zC') and '_FF_13' in str(r['predictor'])
            and isinstance(r['p'], (int, float)) and r['p'] < 0.05
            and all(isinstance(r[k], (int, float)) for k in ('hr', 'll', 'ul'))]

# Preserve the original Figure 3 presentation order (not a ranked ordering).
order = ['C3G', 'C3N', 'C3H', 'C4K', 'C4R',
         'C6I', 'C6L', 'C6H', 'C6K',
         'C8H', 'C8P', 'C8B', 'C9S']
by_code = {str(r['predictor'])[1:].split('_FF_13')[0].upper(): r for r in selected}
if set(by_code) != set(order):
    raise ValueError(f'Figure selection differs from expected 13 items: '
                     f'missing={set(order)-set(by_code)}, extra={set(by_code)-set(order)}')
selected = [by_code[c] for c in order]

colors = {'C3':'#178D92', 'C4':'#487CB8', 'C6':'#8B5CB4',
          'C8':'#D57A39', 'C9':'#B24B78'}
fig, ax = plt.subplots(figsize=(16.5, 8.8), dpi=200)
fig.patch.set_facecolor('white')
fig.subplots_adjust(left=0.47, right=0.76, top=0.94, bottom=0.13)
y = np.arange(len(selected))[::-1]
for i, (r, yi) in enumerate(zip(selected, y)):
    if i % 2 == 0:
        ax.axhspan(yi-0.47, yi+0.47, color='#F2F6F9', zorder=0)
    hr, lo, hi = (float(r[k]) for k in ('hr','ll','ul'))
    color = colors[str(r['predictor'])[1:3].upper()]
    ax.errorbar(hr, yi, xerr=[[hr-lo],[hi-hr]], fmt='o', color=color,
                ecolor=color, elinewidth=2, capsize=3, markersize=6, zorder=3)

codes = [str(r['predictor'])[1:].split('_FF_13')[0].upper() for r in selected]
# The predictor has a leading 'z' because it was z-score standardized.
full_codes = [str(r['predictor']) for r in selected]
item_names = [labels.get(c + '_FF_13', str(r['predictor_label']).strip())
              for c, r in zip(codes, selected)]
ax.set_yticks(y)
ax.set_yticklabels([f'{name}   [{code}]' for name, code in zip(item_names, full_codes)], fontsize=10.5)
ax.tick_params(axis='y', length=0, pad=10)
ax.set_xscale('log')
ax.set_xlim(0.6, 1.4)
ax.xaxis.set_major_locator(FixedLocator([0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4]))
ax.xaxis.set_major_formatter(FormatStrFormatter('%.1f'))
ax.minorticks_off()
ax.tick_params(axis='x', labelsize=10, pad=7)
ax.set_xlabel('Hazard ratio (log scale)', fontsize=12, labelpad=14)
ax.axvline(1, color='#566577', linestyle='--', linewidth=1.4, zorder=1)
ax.set_ylim(-0.7, len(selected)-0.3)
for spine in ax.spines.values(): spine.set_visible(False)
ax.spines['bottom'].set_visible(True)

# Numeric annotations outside the plotting axes (not a figure title/legend).
fig.text(0.075, 0.965, 'Food item [original variable code]',
         fontsize=11, weight='bold', ha='left')
fig.text(0.79, 0.965, 'HR (95% CI)', fontsize=11, weight='bold', ha='left')
fig.text(0.955, 0.965, 'P', fontsize=11, weight='bold', ha='left')
for r, yi in zip(selected, y):
    ypos = ax.transData.transform((1, yi))[1]
    ypos = fig.transFigure.inverted().transform((0, ypos))[1]
    hr, lo, hi = (float(r[k]) for k in ('hr','ll','ul'))
    p = float(r['p'])
    fig.text(0.79, ypos, f'{hr:.2f} ({lo:.2f}–{hi:.2f})',
             fontsize=10.5, ha='left', va='center')
    fig.text(0.955, ypos, '<0.001' if p < 0.001 else f'{p:.3f}',
             fontsize=10.5, ha='left', va='center')

fig.savefig(str(OUT)+'.png', dpi=300, facecolor='white')
fig.savefig(str(OUT)+'.pdf', facecolor='white')
plt.close(fig)

# Single-slide PowerPoint with no title or figure legend.
prs = Presentation()
prs.slide_width = Inches(16.5)
prs.slide_height = Inches(8.8)
slide = prs.slides.add_slide(prs.slide_layouts[6])
slide.shapes.add_picture(str(OUT)+'.png', 0, 0,
                         width=prs.slide_width, height=prs.slide_height)
prs.save(str(OUT)+'.pptx')
print('Created:', *(str(OUT)+'.'+ext for ext in ('png','pdf','pptx')), sep='\n')
print('Displayed items:', len(selected))
print('FDR significant among displayed:', sum(str(r['fdr_significant_q05']).lower()=='yes' for r in selected))
