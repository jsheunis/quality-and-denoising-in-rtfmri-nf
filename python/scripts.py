import webbrowser
import pandas as pd
import ipywidgets as widgets
import qgrid
from IPython.display import display, IFrame


def show_table1(fn):
    df_studies = pd.read_csv(fn, sep='\t', lineterminator='\r')
    df_studies = df_studies.dropna(axis='columns')
    qgrid_widget = qgrid.show_grid(df_studies, show_toolbar=False)
    btn2 = widgets.Button(description='Open Paper')
    display(btn2)
    
    def btn2_eventhandler(obj):
        idx = qgrid_widget.get_selected_rows()
        # generate an URL
        for i in idx:
            url = 'https://www.doi.org/' + df_studies.iloc[i]['doi']
            webbrowser.open(url)
            
    btn2.on_click(btn2_eventhandler)
    return qgrid_widget


def show_table2(fn):
    df_studies = pd.read_csv(fn, sep='\t', lineterminator='\r')
    df_studies = df_studies.dropna(axis='columns')
    colnames = {
        "Vendor": "vendor",
        "Field strength": "magnet",
        "Software": "software",
        "Slice time correction": "stc",
        "Movement correction": "mc",
        "Spatial smoothing": "ss",
        "Drift removal": "dr",
        "Head movement parameter regression": "hmp",
        "Temporal smoothing": "ts",
        "Frequency filtering": "ff",
        "Outlier removal": "or",
        "Differential ROI": "droi",
        "Respiratory noise removal": "resp"
    }
    ALL = 'ALL'
    def unique_sorted_values_plus_ALL(array):
        unique = array.unique().tolist()
        unique.sort()
        unique.insert(0, ALL)
        return unique

    output_grid = widgets.Output()

    cols = df_studies.columns.tolist()
    cols.remove('author')
    cols.remove('doi')
    dropdown_cols = widgets.Dropdown(options = colnames.keys(), value = 'Vendor')
    dropdown_col_opts = widgets.Dropdown(options = unique_sorted_values_plus_ALL(df_studies.vendor))

    def dropdown_cols_eventhandler(change):
        output_grid.clear_output()
        dropdown_col_opts.options = unique_sorted_values_plus_ALL(df_studies[colnames[change.new]])
        with output_grid:
            display(df_studies)

    def dropdown_col_opts_eventhandler(change):
        output_grid.clear_output()
        with output_grid:
            if (change.new == ALL):
                display(df_studies)
            else:
                display(df_studies[df_studies[colnames[dropdown_cols.value]] == change.new])

    dropdown_cols.observe(dropdown_cols_eventhandler, names='value')
    dropdown_col_opts.observe(dropdown_col_opts_eventhandler, names='value')
    
    return dropdown_cols, dropdown_col_opts, output_grid

def show_plots(fn):
    df_studies = pd.read_csv(fn, sep='\t', lineterminator='\r')
    df_studies = df_studies.dropna(axis='columns')
    cols = df_studies.columns.tolist()
    cols.remove('author')
    cols.remove('doi')
    colnames = {
        "Vendor": "vendor",
        "Field strength": "magnet",
        "Software": "software",
        "Slice time correction": "stc",
        "Movement correction": "mc",
        "Spatial smoothing": "ss",
        "Drift removal": "dr",
        "Head movement parameter regression": "hmp",
        "Temporal smoothing": "ts",
        "Frequency filtering": "ff",
        "Outlier removal": "or",
        "Differential ROI": "droi",
        "Respiratory noise removal": "resp"
    }
    dropdown_cols2 = widgets.Dropdown(options = colnames.keys(), value = 'Vendor')
    output_plot = widgets.Output()

    def dropdown_cols2_eventhandler(change):
        output_plot.clear_output()
        with output_plot:
            series = df_studies[colnames[change.new]].value_counts()
            series.head()
            series.iplot(kind='bar', xTitle='Options',
                         yTitle='Amount of studies',
                         title=dropdown_cols2.value,
                         filename='cufflinks/bar-chart')
    dropdown_cols2.observe(dropdown_cols2_eventhandler, names='value')
    
    return dropdown_cols2, output_plot
