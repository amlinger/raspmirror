import os
from flask      import Flask, render_template
from flask.ext  import assets

# Create the app and the possivility to modify the environment.
app = Flask(__name__)
app.config['ASSETS_DEBUG'] = True

assets_env              = assets.Environment(app)
assets_env.debug        = True
assets_env.cache        = False
assets_env.manifest     = None
assets_env.auto_build   = True
assets_env.url          = 'static/'
# assets_env.directory    = '/'
# assets_env.cache        = ".webassets-cache"

# Tell flask-assets where to look for our coffeescript and sass files.
assets_env.load_path = [
    os.path.join(os.path.dirname(__file__), 'sass'),
    os.path.join(os.path.dirname(__file__), 'coffee'),
    os.path.join(os.path.dirname(__file__), 'bower_components'),
]

assets_env.register(
    'js_all',
    assets.Bundle(
        'jquery/dist/jquery.min.js',
        'handlebars/handlebars.js',
        'ember/ember.js',
        'ember-data/ember-data.js',
        'moment/moment.js',
        assets.Bundle(
            '*.coffee',
            'controllers/*.coffee',
            'models/*.coffee',
            'routes/*.coffee',
            depends = '*.coffeescript',
            filters = ['coffeescript'],
            output  = 'app.js'
        ),
        output = 'js_all.js'
    )
)

assets_env.register(
    'css_all',
    assets.Bundle(
        'all.sass',
        depends='*.sass',
        filters='sass',
        output='css_all.css'
    )
)

def handlebars_templates():
    templates = []
    path = os.path.join(os.path.dirname(__file__), 'templates')
    try: lst = os.listdir(path)
    except OSError:
        pass #ignore errors
    else:
        for name in lst:
            if name.endswith('handlebars'):
                with open(os.path.join(path, name)) as template:
                    templates.append({
                        'name'    : name.replace('.handlebars', ''),
                        'content' : template.read()})
        return templates

@app.route('/')
def hello_world():
    print handlebars_templates()
    return render_template('index.html', handlebars_templates = handlebars_templates())



# Debug mode is okay, since we never intend to have that many outgoing 
# connections. Performance is (hopefully) not an issue :)
app.debug = True

if __name__ == '__main__':
    app.run(host='0.0.0.0')