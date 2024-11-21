// PUNTO 6
object buscadorPersonasConCosas {
  method encontrarQuienTieneMasCosas(personas) {
    personas.max({ per => 
      per.cosasCompradas().size()
    })
  }  
}

// No llege a implementar, pero la idea es implementar composicion en tipoDeConsumidor
// De esta forma implementamos en cada caso la logica especial para compra y para pago de manera polimorfica
// y reescribiendo la menor cantidad de codigo 
object compradorCompulsivo {
  method comprar() {}
  method pagar() {}
}

object pagadorCompulsivo {
  method comprar() {}
  method pagar() {}
}

class Persona {
  const tipoDeConsumidor = pagadorCompulsivo

  const cosasCompradas = []
  method cosasCompradas() = cosasCompradas

  var sueldo = 100
  
  // Metodos de pago
  const tarjetasCredito = []
  const cuotas = []
  method cuotas() = cuotas

  const tarjetasDebito = []

  const dineroEfectivo = new Efectivo(dinero=100)
  method dineroEfectivo() = dineroEfectivo

  var formaPagoPreferida = dineroEfectivo
  method formaPagoPreferida() = formaPagoPreferida


  method cambiarFormaPago(formaPago) {
    const esCredito = tarjetasCredito.contains(formaPago)
    const esDebito = tarjetasDebito.contains(formaPago)
    const esEfectivo = formaPago == dineroEfectivo

    if(esCredito or esDebito or esEfectivo)
      formaPagoPreferida = formaPago
  }

  method comprar(cosa, monto) {
    if(formaPagoPreferida.puedePagar(monto)) {
      formaPagoPreferida.pagar(monto, self)
      cosasCompradas.add(cosa)
    }
  }

  method cobrar() {
    meses.pasarMes() // Pasa el mes

    var dineroRestante = sueldo

    cuotas.forEach({ cu =>
      const tieneQuePagarla = cu.mesVencimiento() <= meses.mesActual()
      const puedePagarla = dineroRestante - cu.monto() > 0

      if(tieneQuePagarla and puedePagarla) {
        dineroRestante -= cu.monto()
        cu.pagarCuota()

        // Si termino de pagar todas las cuotas se elimina
        if(cu.cuotasRestantes() <= 0)
          cuotas.remove(cu)
      }
    })
    // Guarda el efectivo restante
    dineroEfectivo.agregar(dineroRestante)
  }

  method aumentoSueldo(newSueldo) {
    if(newSueldo > sueldo)
      sueldo = newSueldo
  }

  method montoTotalVencido() {
    var monto = 0
    cuotas.forEach({ cu =>
      if(cu.mesVencimiento() <= meses.mesActual()) 
        monto += cu.monto() * cu.cuotasRestantes()
    })
    return monto
  }

}

class Cuota {
  var cuotasRestantes
  var mesVencimiento // Mes Vto de la siguiente cuota
  const monto // Monto individual de cada cuota

  method cuotasRestantes() = cuotasRestantes
  method pagarCuota() {
    cuotasRestantes -= 1
    mesVencimiento += 1
  }

  method mesVencimiento() = mesVencimiento
  method monto() = monto
}

// ================================================
// FORMAS DE PAGO
// ================================================
class FormaDePago {
  var dinero
  method dinero() = dinero

  method puedePagar(monto) = dinero - monto >= 0

  method pagar(monto, persona) {
    dinero -= monto
  }
}


class Efectivo inherits FormaDePago {
  method agregar(monto) {
    dinero += monto
  }
}

class TarjetaDebito inherits FormaDePago {
  // No tiene comportamiento adicional
}

class TarjetaCredito inherits FormaDePago(dinero=0) {
  const bancoEmisor
  
  override method puedePagar(monto) = bancoEmisor.montoMaximo() >= monto

  override method pagar(monto, persona) {
    const cantCuotas = bancoEmisor.cantCuotas()
    const montoCuota = monto * bancoEmisor.tasaInteres() / cantCuotas
    const mesVto = meses.mesActual() + 1
    
    // Asigna una cuota y se la añade a la persona
    const nuevaCuota = new Cuota( mesVencimiento=mesVto, monto=montoCuota, cuotasRestantes=cantCuotas )
    persona.cuotas().add(nuevaCuota)
  }
}

// PUNTO 5 : Siempre puede pagar y es una cuota de 10 pesos
class TarjetaCreditoPdeP inherits TarjetaCredito(bancoEmisor=bancoCentral) {
  override method puedePagar(monto) = true
  
  override method pagar(monto, persona) {
    const mesVto = meses.mesActual() + 1
    const nuevaCuota = new Cuota( mesVencimiento=mesVto, monto=10, cuotasRestantes=1 )
    persona.cuotas().add(nuevaCuota)
  }
}

// ================================================
// BANCOS
// ================================================

class Banco {
  const montoMaximo
  const cantCuotas
  
  method tasaInteres() = bancoCentral.tasaInteres()
  method montoMaximo() = montoMaximo
  method cantCuotas() = cantCuotas
}

object bancoCentral {
  method tasaInteres() = 1.1 // 10%
}

// ================================================
// MESES
// ================================================

object meses {
  var mesActual = 1
  method mesActual() = mesActual

  method pasarMes() {
    mesActual += 1
  }
}