cronAdd("update_rappels", "*/1 * * * *", () => {
  (async () => {
    try {
      console.log("Mise à jour des rappels...");

      const url = "https://codelabs.formation-flutter.fr/assets/rappels.json";

      const res = $http.send({
        method: "GET",
        url: url,
        timeout: 120,
      });

      const data = res.json;

      for (const item of data) {
        if (!item.gtin) continue;

        // Cherche si le record existe déjà (par numero_fiche)
        let record = null;
        try {
          record = await $app.findFirstRecordByData(
            "rappels",
            "numero_fiche",
            item.numero_fiche
          );
        } catch (e) {
          record = new Record($app.findCollectionByNameOrId("rappels"));
        }

        // --- Champs à conserver ---
        record.set("gtin", String(item.gtin));
        record.set("numero_fiche", item.numero_fiche || "");

        // --- Champs demandés ---
        record.set("liens_vers_les_images", item.liens_vers_les_images || "");
        record.set("date_debut_commercialisation", item.date_debut_commercialisation || "");
        record.set("date_date_fin_commercialisation", item.date_date_fin_commercialisation || "");
        record.set("distributeurs", item.distributeurs || "");
        record.set("zone_geographique_de_vente", item.zone_geographique_de_vente || "");
        record.set("motif_rappel", item.motif_rappel || "");
        record.set("risques_encourus", item.risques_encourus || "");
        record.set("informations_complementaires", item.informations_complementaires || "");
        record.set("conduites_a_tenir_par_le_consommateur", item.conduites_a_tenir_par_le_consommateur || "");
        record.set("lien_vers_affichette_pdf", item.lien_vers_affichette_pdf || "");

        record.set("actif", true);

        await $app.save(record);
      }

      console.log("Mise à jour terminée.");
    } catch (err) {
      console.log("ERREUR update_rappels:", err);
    }
  })();
});