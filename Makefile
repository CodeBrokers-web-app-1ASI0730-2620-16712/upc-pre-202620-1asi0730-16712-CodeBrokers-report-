.PHONY: pdf clean

pdf:
	@echo Generando PDF con Pandoc...
	@if not exist build mkdir build
	pandoc --sandbox --defaults=config/defaults.yaml
	@echo ¡PDF generado exitosamente en la carpeta build/!

clean:
	@echo Limpiando directorio de construccion...
	@if exist build rmdir /S /Q build