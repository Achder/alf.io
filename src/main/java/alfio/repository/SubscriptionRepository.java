/**
 * This file is part of alf.io.
 *
 * alf.io is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * alf.io is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with alf.io.  If not, see <http://www.gnu.org/licenses/>.
 */
package alfio.repository;

import alfio.model.PriceContainer;
import alfio.model.SubscriptionDescriptor;
import alfio.model.support.JSONData;
import ch.digitalfondue.npjt.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@QueryRepository
public interface SubscriptionRepository {

    @Query("insert into subscription_descriptor (id, max_entries, valid_from, valid_to, price_cts, vat, vat_status, currency, availability, is_public, title, description, organization_id_fk) " +
           " values(:id, :maxEntries, :validFrom, :validTo, :priceCts, :vat, :vatStatus::VAT_STATUS, :currency, :availability::SUBSCRIPTION_AVAILABILITY, :isPublic, :title::jsonb, :description::jsonb, :organizationId)")
    int createSubscriptionDescriptor(@Bind("id") UUID id,
                                     @Bind("maxEntries") int maxEntries,
                                     @Bind("validFrom") ZonedDateTime validFrom, @Bind("validTo") ZonedDateTime validTo,
                                     @Bind("priceCts") int priceCts, @Bind("vat") BigDecimal vat,
                                     @Bind("vatStatus") PriceContainer.VatStatus vatStatus, @Bind("currency") String currency,
                                     @Bind("availability") SubscriptionDescriptor.SubscriptionAvailability availability,
                                     @Bind("isPublic") boolean isPublic,
                                     @Bind("title") @JSONData Map<String, String> title,
                                     @Bind("description") @JSONData Map<String, String> description,
                                     @Bind("organizationId") int organizationId);

    @Query("select * from subscription_descriptor where organization_id_fk = :organizationId order by creation_ts asc")
    List<SubscriptionDescriptor> findAllByOrganizationIds(@Bind("organizationId") int organizationId);

    @Query("select * from subscription_descriptor where is_public = true and (max_entries > 0 or max_entries = -1) and valid_from <= now() and valid_to >= now() order by valid_from asc")
    List<SubscriptionDescriptor> findAllActiveAndPublic();
}
