# vespa

Este es el flujo de trabajo Git utilizado por el equipo:

En primer lugar, configura el entorno de Jupyter Lab con la [extensión Git](https://github.com/jupyterlab/jupyterlab-git). Esto es sólo para Windows:
1. Instala Anaconda
2. Ejecuta `conda install -c conda-forge jupyterlab-git` en el terminal de conda
3. En la terminal de conda, ejecuta `conda install -c conda-forge nodejs`
4. En la terminal de conda, ejecuta `conda install -c anaconda git` (si es la primera vez que instalas Git, entonces quizás también configures tus credenciales: `git config --global user.name "Tu nombre aquí"`
`git config --global user.email "your_email@example.com"`)
5. Abrir jupyterlab
6. Habilitar las extensiones (icono del puzzle en la barra de la izquierda)
7. Desplázate hasta @jupyterlab/git y haz clic en `instalar`.
8. Cuando jupyterlab te pida construir la extensión git, haz clic en `build`. Luego espera a que termine y vuelve a cargar jupyterlab
9. Tal vez, sólo tal vez, una actualización de git desde la consola de jupyterlab puede estar en orden `pip install --upgrade jupyterlab-git`
10. Tal vez, sólo tal vez, si la clonación no funciona a la primera prueba en la consola de jupyterlab `git clone <repo url>` directamente
11. ¿Sigue sin funcionar? Reinicia todo. Tu portátil, Jupyter, Conda. Todo ello. Quizás un par de veces.
12. **NO** actualices el navegador Anaconda ni Jupyter Lab más allá de lo que viene por defecto en la instalación inicial.

Ahora, a trabajar:
1. Una sola vez: **"CLONE "** este repositorio en tu entorno local de JupyterLab, utilizando la [URL HTTPS](https://github.com/IEwaspbusters/KopuruVespaCompetitionIE.git)
4. **TIRAR**. Para cada vez que edites en el rango ([ahora, fecha límite, diario]), antes de editar, asegúrate de que siempre **"Tiras desde remoto "** la última versión del repositorio
5. Edite cualquier script y datos que necesite en la carpeta de envío y de lotes correspondiente. Se prefieren los archivos **.IPYNB** en la mayoría de los casos
6. **STAGE** cualquier archivo _Changed_ o _Untracked_ (haciendo clic en el "+") que desee confirmar (es decir, "guardar")
7. **COMITAR**. Escriba un breve resumen de los cambios que está introduciendo y luego haga clic en **Commit**.
8. **PUSH**. Ahora **Push to remote** el commit que acabas de hacer para verlos reflejados en [el repo de GitHub de WaspBuster](https://github.com/IEwaspbusters/KopuruVespaCompetitionIE)
