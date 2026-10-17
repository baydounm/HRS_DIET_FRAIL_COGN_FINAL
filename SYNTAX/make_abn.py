import openpyxl, subprocess, os
from pptx import Presentation
from pptx.util import Inches
from pptx.dml.color import RGBColor
s=openpyxl.load_workbook('/mnt/data/abn5.xlsx',read_only=True).worksheets[0]
rows=list(s.values)[1:]
labels={'AGE_pm':'Age','SEX':'Sex','NHB':'Non-Hispanic Black','HISP':'Hispanic','OTHER':'Other race','zses_2012_pm':'SES score','married_2012':'Married','zhei2015_total_score_pm':'HEI-2015','smoking_2012':'Smoking','alcohol_2012':'Alcohol use','physic_act_2012':'Physical activity','bmibr_2012':'BMI','hbp_ever_2012':'Hypertension','diab_ever_2012':'Diabetes','heart_ever_2012':'Heart disease','stroke_ever_2012':'Stroke','srh_2012':'Self-rated health','fried_sum_pm':'Frailty score','d_outcome':'Incident cognitive impairment','t2':'Time indicator t2','t3':'Time indicator t3'}
colors={'dem':'#E8F3FF','ses':'#E5F7ED','diet':'#FFF1D8','clinical':'#EEE8FF','out':'#FFE4ED'}
groups={'dem':['AGE_pm','SEX','NHB','HISP','OTHER'],'ses':['zses_2012_pm','married_2012'],'diet':['zhei2015_total_score_pm','smoking_2012','alcohol_2012'],'clinical':['srh_2012','physic_act_2012','bmibr_2012','hbp_ever_2012','diab_ever_2012','heart_ever_2012','stroke_ever_2012'],'out':['fried_sum_pm','t2','t3','d_outcome']}
# dashed when target is binary: marriage, hypertension, diabetes, heart disease, stroke, d_outcome
binary={'married_2012','hbp_ever_2012','diab_ever_2012','heart_ever_2012','stroke_ever_2012','d_outcome'}
lines=['digraph ABN {','graph [rankdir=LR, bgcolor="white", pad="0.3", nodesep="0.38", ranksep="1.5", splines=polyline, outputorder=edgesfirst, fontname="Arial"];','node [shape=box, style="rounded,filled", fontname="Arial", fontsize=15, color="#556070", penwidth=1.3, margin="0.16,0.10"];','edge [fontname="Arial",fontsize=10, arrowsize=0.6, penwidth=1.25];']
for group,ns in groups.items():
 for n in ns:
  lines.append('"%s" [label="%s",fillcolor="%s",%s];'%(n,labels[n],colors[group], 'penwidth=2.5,color="#C14C7A"' if n in ['fried_sum_pm','d_outcome'] else ''))
# guide ordering via invisible edges
for ns in groups.values():
 lines.append('{rank=same; '+ '; '.join('"'+n+'"' for n in ns)+';}')
for a,b,coef,*_ in rows:
 if a is None or b is None:continue
 color='#C94B42' if coef>0 else '#2166AC'
 val=('−' if coef<0 else '+')+f'{abs(coef):.2f}'
 lines.append('"%s" -> "%s" [color="%s",fontcolor="%s",style="%s",label="%s",weight=1];'%(a,b,color,color,'dashed' if b in binary else 'solid',val))
lines.append('}')
open('/mnt/data/abn_correct.dot','w').write('\n'.join(lines))
subprocess.run(['dot','-Tpng','-Gdpi=145','/mnt/data/abn_correct.dot','-o','/mnt/data/ABN_corrected_relationships.png'],check=True)
subprocess.run(['dot','-Tsvg','/mnt/data/abn_correct.dot','-o','/mnt/data/ABN_corrected_relationships.svg'],check=True)
from PIL import Image
im=Image.open('/mnt/data/ABN_corrected_relationships.png'); print('image',im.size)
p=Presentation();p.slide_width=Inches(16);p.slide_height=Inches(9)
slide=p.slides.add_slide(p.slide_layouts[6]); slide.shapes.add_picture('/mnt/data/ABN_corrected_relationships.png',Inches(.2),Inches(.3),width=Inches(15.6),height=Inches(8.15))
t=slide.shapes.add_textbox(Inches(.4), Inches(8.55), Inches(15), Inches(.3));t.text_frame.text='Red: positive coefficient   |   Blue: negative coefficient   |   Dashed: arrow into binary node   |   Source: Supplementary Datasheet 5 (57 edges)'
p.save('/mnt/data/Figure5_ABN_Corrected.pptx')
print('edges',len(rows))
